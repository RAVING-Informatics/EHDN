#!/bin/bash -l
#SBATCH --job-name=ehdn_postprocess
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

# Load conda env
source /scratch/pawsey0933/cfolland/miniforge3/etc/profile.d/conda.sh
conda activate /scratch/pawsey0933/cfolland/conda_envs/ehdn

# Paths
working_dir=/scratch/pawsey0933/cfolland/EHDN/
ref_tr_bed=$working_dir/refs/Homo_sapiens_assembly38.trf_period1-6.dedup.sorted.bed
disease_loci=$working_dir/refs/variant_catalogs/variant_catalog_without_offtargets.GRCh38.json
annotate_script=$working_dir/scripts/annotate_EHdn_locus_outliers.py

mkdir -p $working_dir/results/cc/postprocess/
mkdir -p $working_dir/results/outlier/postprocess/

# Annotate case-control results
for file in $working_dir/results/cc/*annotated.tsv; do
  echo "Annotating: $file"
  python3 $annotate_script \
    --reference-tr-bed-file "$ref_tr_bed" \
    --known-disease-associated-loci "$disease_loci" \
    -o "$working_dir/results/cc/postprocess/" \
    --verbose \
    "$file"
done

# Annotate outlier results
for file in $working_dir/results/outlier/*annotated.tsv; do
  echo "Annotating: $file"
  python3 $annotate_script \
    --reference-tr-bed-file "$ref_tr_bed" \
    --known-disease-associated-loci "$disease_loci" \
    -o "$working_dir/results/outlier/postprocess/" \
    --verbose \
    "$file"
done
