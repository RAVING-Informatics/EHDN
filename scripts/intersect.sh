#!/bin/bash
input_dir=$1

sed -i '1d' *.annotated.annotated.tsv

ls $input_dir | grep 'annotated.annotated.tsv' | while read -r line ; do
basename=${line%%.*}
bedtools intersect -a $line -b *.annotated.annotated.tsv -c > ${basename}_results.tsv 
cat header.txt ${basename}_results.tsv > ${basename}_results_header.tsv 
done
