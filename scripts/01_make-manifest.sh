#!/bin/sh
ref=/data/references/Homo_sapiens_assembly38.fasta #path to reference sequence
input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*} 
    echo "Generate manifest for ${basename}"
    cp $working_dir/manifests/manifest.tsv $working_dir/manifests/$basename.manifest.tsv
    sed -i 's|basename|'$basename'|g' /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/manifests/$basename.manifest.tsv ;
done