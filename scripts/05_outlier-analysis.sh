#!/bin/sh
#expansion hunter de novo outlier analysis
input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*} 

echo "Compute locus outliers for ${basename}"
/data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/outlier.py locus \
        --manifest $working_dir/manifests/$basename.manifest.tsv \
        --multisample-profile $working_dir/str-profiles/merged/$basename.multisample_profile.json \
        --output $working_dir/results/$basename.outlier_locus.tsv
done