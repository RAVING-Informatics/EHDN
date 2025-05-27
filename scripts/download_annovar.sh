#!/bin/bash -l
#SBATCH --job-name=download_annovar
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

#Load conda env
source /scratch/pawsey0933/cfolland/miniforge3/etc/profile.d/conda.sh
conda activate /scratch/pawsey0933/cfolland/conda_envs/ehdn

# Paths

annovar=/software/projects/pawsey0933/EHDN/annovar

perl $annovar/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGene $annovar/humandb/
