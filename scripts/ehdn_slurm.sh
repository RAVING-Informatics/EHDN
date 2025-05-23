#!/bin/bash -l
#SBATCH --job-name=ehdn
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

set -euo pipefail

# Input parameters
line="$1"

#Load conda env
source /scratch/pawsey0933/cfolland/miniforge3/etc/profile.d/conda.sh
conda activate /scratch/pawsey0933/cfolland/conda_envs/stripy

# Paths
ref=/software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta
input_dir=/scratch/pawsey0933/gmonahan/preprocessed/neuro/
working_dir=/scratch/pawsey0933/cfolland/EHDN/
basename=${line%%.*}
ehdn=/software/projects/pawsey0933/EHDN/bin/ExpansionHunterDenovo

# Generate manifest
manifest_path=$working_dir/manifests/$basename.manifest.tsv
if [ ! -f "$manifest_path" ]; then
    echo "Generating manifest for ${basename}"
    cp $working_dir/manifests/manifest.tsv "$manifest_path"
    sed -i 's|basename|'$basename'|g' "$manifest_path"
else
    echo "Manifest already exists: $manifest_path"
fi

# Profile STRs
profile_prefix=$working_dir/str-profiles/$basename
if [ ! -f "${profile_prefix}.json" ]; then
    echo "Profiling ${basename}"
    $ehdn profile \
        --reads $input_dir/$line \
        --reference $ref \
        --output-prefix "$profile_prefix" \
        --min-anchor-mapq 50 \
        --max-irr-mapq 40
else
    echo "Profile already exists: ${profile_prefix}.json"
fi

# Merge STR profiles
merged_prefix=$working_dir/str-profiles/merged/$basename
if [ ! -f "${merged_prefix}.multisample_profile.json" ]; then
    echo "Merging ${basename}" 
    $ehdn merge \
        --reference $ref \
        --manifest "$manifest_path" \
        --output-prefix "$merged_prefix"
else
    echo "Merged profile already exists: ${merged_prefix}.multisample_profile.json"
fi

# Outlier analysis
outlier_result=$working_dir/results/outlier/${basename}.outlier_locus.tsv
if [ ! -f "$outlier_result" ]; then
    echo "Computing locus outliers for ${basename}"
    $working_dir/scripts/outlier.py locus \
        --manifest "$manifest_path" \
        --multisample-profile "${merged_prefix}.multisample_profile.json" \
        --output "$outlier_result"
else
    echo "Outlier results already exist: $outlier_result"
fi

# Case-control analysis
cc_result=$working_dir/results/cc/${basename}.CC_locus.tsv
if [ ! -f "$cc_result" ]; then
    echo "Computing case-control locus analysis for ${basename}"
    $working_dir/scripts/casecontrol.py locus \
        --manifest "$manifest_path" \
        --multisample-profile "${merged_prefix}.multisample_profile.json" \
        --output "$cc_result"
else
    echo "Case-control results already exist: $cc_result"
fi

# Annotation
annotated_outlier=$working_dir/results/outlier/${basename}.outlier_locus.annotated.tsv
if [ ! -f "$annotated_outlier" ]; then
    echo "Annotating outlier results for ${basename}"
    bash $working_dir/scripts/annotate_ehdn.sh \
        --ehdn-results "$outlier_result" \
        --ehdn-annotated-results "$annotated_outlier" \
        --annovar-annotate-variation /data/annovar/annotate_variation.pl \
        --annovar-humandb /data/annovar/humandb \
        --annovar-buildver hg38
else
    echo "Annotated outlier result already exists: $annotated_outlier"
fi

annotated_cc=$working_dir/results/cc/${basename}.CC_locus.annotated.tsv
if [ ! -f "$annotated_cc" ]; then
    echo "Annotating case-control results for ${basename}"
    bash $working_dir/scripts/annotate_ehdn.sh \
        --ehdn-results "$cc_result" \
        --ehdn-annotated-results "$annotated_cc" \
        --annovar-annotate-variation /data/annovar/annotate_variation.pl \
        --annovar-humandb /data/annovar/humandb \
        --annovar-buildver hg38
else
    echo "Annotated case-control result already exists: $annotated_cc"
fi

# Cleanup
[ -f "$cc_result" ] && rm "$cc_result"
[ -f "$outlier_result" ] && rm "$outlier_result"
