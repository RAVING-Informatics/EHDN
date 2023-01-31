#!/bin/sh
#merge str profiles computed using Expansion Hunter Denovo

ref=/data/references/Homo_sapiens_assembly38.fasta #path to reference sequence
input_dir=$1 #path to input directory

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*}
    echo "Merging ${basename}" 
    ExpansionHunterDenovo merge \
        --reference $ref \
        --manifest /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/manifests/$basename.manifest.tsv \
        --output-prefix /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/str-profiles/merged/$basename ; 
        done