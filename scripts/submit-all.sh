#!/bin/bash

input_dir=/scratch/pawsey0933/gmonahan/preprocessed/rpl

ls "$input_dir" | grep -E '\.bam$|\.cram$' | grep -v -E '\.bai$|\.crai$|\.md5$' | while read -r file; do
    echo "Submitting job for $file"
    sbatch run-ehdn.sh "$file"
done
