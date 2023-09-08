#!/bin/sh
#compute str-profile from all files in an input directory

ref=/data/references/Homo_sapiens_assembly38.fasta #path to reference sequence
input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*} 
    echo "Profiling ${basename}"
    ExpansionHunterDenovo profile \
        --reads $input_dir/$line \
        --reference $ref \
        --output-prefix $working_dir/str-profiles/$basename \
        --min-anchor-mapq 50 \
        --max-irr-mapq 40 \ ;
        done