#!/bin/sh
#merge str profiles computed using Expansion Hunter Denovo

ref=/data/references/Homo_sapiens_assembly38.fasta #path to reference sequence
input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*}
    echo "Merging ${basename}" 
    ExpansionHunterDenovo merge \
        --reference $ref \
        --manifest $working_dir/manifests/$basename.manifest.tsv \
        --output-prefix $working_dir/str-profiles/merged/$basename ; 
        done