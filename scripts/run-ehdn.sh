#!/bin/bash -l
#SBATCH --job-name=ehdn
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

source /software/projects/pawsey0933/cfolland/miniconda3/etc/profile.d/mamba.sh
mamba activate /software/projects/pawsey0933/cfolland/miniforge3/envs/ehdn 

# Input parameters
line="$1"

# Paths
ref=/software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta
input_dir=/scratch/pawsey0933/gmonahan/preprocessed/rpl
working_dir=/scratch/pawsey0933/cfolland/EHDN/
basename=${line%%.*}
ehdn=/software/projects/pawsey0933/EHDN/bin/ExpansionHunterDenovo
annovar=/software/projects/pawsey0933/EHDN/annovar

# Generate manifest
mkdir -p $working_dir/manifests/
manifest_path=$working_dir/manifests/$basename.manifest.tsv
if [ ! -f "$manifest_path" ]; then
    echo "Generating manifest for ${basename}"
    cp $working_dir/manifests/manifest.tsv "$manifest_path"
    sed -i 's|basename|'$basename'|g' "$manifest_path"
else
    echo "Manifest already exists: $manifest_path"
fi

# Profile STRs
mkdir -p $working_dir/str-profiles/
profile_prefix=$working_dir/str-profiles/$basename
if [ ! -f "${profile_prefix}.str_profile.json" ]; then
    echo "Profiling ${basename}"
    $ehdn profile \
        --reads $input_dir/$line \
        --reference $ref \
        --output-prefix "$profile_prefix" \
        --min-anchor-mapq 50 \
        --max-irr-mapq 40
else
    echo "Profile already exists: ${profile_prefix}.str_profile.json"
fi

# Merge STR profiles
mkdir -p $working_dir/str-profiles/merged/
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
mkdir -p $working_dir/results/outlier/
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
mkdir -p $working_dir/results/cc/
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
        --annovar-annotate-variation $annovar/annotate_variation.pl \
        --annovar-humandb $annovar/humandb \
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
        --annovar-annotate-variation $annovar/annotate_variation.pl \
        --annovar-humandb $annovar/humandb \
        --annovar-buildver hg38
else
    echo "Annotated case-control result already exists: $annotated_cc"
fi
