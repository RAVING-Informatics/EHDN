#!/bin/bash
input_dir=$1

python3 gene-counts.py $input_dir

sed -i '1d' $input_dir/*.annotated.tsv

ls $input_dir | grep '.annotated.tsv' | while read -r line ; do
basename=${line%%.*}
bedtools intersect -a $input_dir/$line -b $input_dir/*.annotated.tsv -c > $input_dir/${basename}_results.tsv 
cat $input_dir/header.txt $input_dir/${basename}_results.tsv > $input_dir/${basename}_results_header.tsv 
done
