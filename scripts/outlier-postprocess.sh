#!/bin/bash -l
#SBATCH --job-name=ehdn_postprocess
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

set -euo pipefail

module load bedtools/2.30.0--h468198e_3

input_dir=/scratch/pawsey0933/cfolland/EHDN/results/outlier/postprocess
header="/software/projects/pawsey0933/EHDN/scripts/header.tsv"

if [[ ! -d "$input_dir" ]]; then
    echo "Error: Input directory '$input_dir' does not exist!" >&2
    exit 1
fi

if [[ ! -f "$header" ]]; then
    echo "Error: Header file '$header' does not exist!" >&2
    exit 1
fi

is_gzipped() { [[ "$1" == *.gz ]]; }

read_file() {
    if is_gzipped "$1"; then zcat "$1"; else cat "$1"; fi
}

# Return 0 (true) if line has at least 3 tab fields and cols 2&3 are integers
# Also ignores comment lines starting with '#'
filter_to_valid_bed_rows() {
    awk -F'\t' '
        NF >= 3 &&
        $1 !~ /^#/ &&
        $2 ~ /^[0-9]+$/ &&
        $3 ~ /^[0-9]+$/ { print }
    '
}

# (Optional) Keep your header-removal pass, but it's no longer required for bedtools safety
first_line_is_data() {
    local file="$1"
    local first
    if is_gzipped "$file"; then
        first="$(zcat "$file" | head -n1)"
    else
        first="$(head -n1 "$file")"
    fi
    awk -F'\t' -v line="$first" '
        BEGIN {
            n = split(line, a, "\t")
            if (n < 3) exit 1
            if (a[2] ~ /^[0-9]+$/ && a[3] ~ /^[0-9]+$/) exit 0
            exit 1
        }
    '
}

remove_header_if_present() {
    local file="$1"
    local temp_file="${file}.tmp"

    if first_line_is_data "$file"; then
        echo "  First line looks like data; not removing."
        return 0
    fi

    echo "  First line is not valid BED-like data; removing as header."

    if is_gzipped "$file"; then
        zcat "$file" | tail -n +2 | gzip > "$temp_file"
        mv "$temp_file" "$file"
    else
        sed -i '1d' "$file"
    fi
}

echo "Processing files in: $input_dir"

echo "Checking/removing headers from all outlier annotation files..."
for file in "$input_dir"/*.outlier_locus.annotated.*; do
    if [[ -f "$file" ]]; then
        echo "Processing: $(basename "$file")"
        remove_header_if_present "$file"
    fi
done

ls "$input_dir" | grep 'outlier_locus.annotated' | while read -r line ; do
    basename=${line%%.*}
    final_output="$input_dir/${basename}.outlier_postprocessed.sorted.tsv"

    if [[ -f "$final_output" ]]; then
        echo "Output file already exists for $basename: $(basename "$final_output")"
        echo "Skipping $basename (use --force to overwrite)"
        continue
    fi

    echo "Finding intersect for $basename"

    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    query_file="$temp_dir/query.bed"
    # ✅ SANITIZE input for bedtools
    read_file "$input_dir/$line" | filter_to_valid_bed_rows > "$query_file"

    if [[ ! -s "$query_file" ]]; then
        echo "Warning: Query file for $basename has no valid BED rows after filtering." >&2
        continue
    fi

    target_files=()
    for target in "$input_dir"/*.outlier_locus.annotated.*; do
        if [[ -f "$target" ]]; then
            target_temp="$temp_dir/$(basename "$target").bed"
            # ✅ SANITIZE targets for bedtools
            read_file "$target" | filter_to_valid_bed_rows > "$target_temp"

            # Only include non-empty targets
            if [[ -s "$target_temp" ]]; then
                target_files+=("$target_temp")
            fi
        fi
    done

    if [[ ${#target_files[@]} -gt 0 ]]; then
        bedtools intersect -a "$query_file" -b "${target_files[@]}" -c > "$input_dir/${basename}_int.tsv"
    else
        echo "Warning: No target files found (with valid BED rows) for $basename" >&2
        continue
    fi

    cat "$header" "$input_dir/${basename}_int.tsv" > "$input_dir/${basename}_outlier_postprocessed.tsv"

    (head -n1 "$input_dir/${basename}_outlier_postprocessed.tsv" && \
     tail -n +2 "$input_dir/${basename}_outlier_postprocessed.tsv" | sort -k7 -nr) > \
     "$input_dir/${basename}.outlier_postprocessed.sorted.tsv"

    rm "$input_dir/${basename}_int.tsv"
    rm "$input_dir/${basename}_outlier_postprocessed.tsv"

    echo "Completed $basename"
done

echo "All processing complete!"
