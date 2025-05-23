#!/bin/bash

input_dir=/scratch/pawsey0933/gmonahan/preprocessed/neuro/

ls "$input_dir" | grep -E '\.bam$|\.cram$' | grep -v -E '\.bai$|\.crai$' | while read -r file; do
    echo "Submitting job for $file"
    sbatch run-ehdn.sh "$file"
done
