#!/bin/bash
input_dir=$1

#python3 gene-counts.py $input_dir

sed -i '1d' $input_dir/*.outlier_locus.annotated.*

ls $input_dir | grep 'outlier_locus.annotated' | while read -r line ; do
basename=${line%%.*}
echo "finding intersect for $basename"
bedtools intersect -a $input_dir/$line -b $input_dir/*.outlier_locus.annotated.* -c > $input_dir/${basename}_int.tsv 
cat /data/ExpansionHunterDenovo/refs/header.tsv $input_dir/${basename}_int.tsv > $input_dir/${basename}_outlier_postprocessed.tsv 
(head -n1 $input_dir/${basename}_outlier_postprocessed.tsv && tail -n +2 $input_dir/${basename}_outlier_postprocessed.tsv | sort -k7 -r ) > $input_dir/${basename}.outlier_postprocessed.sorted.tsv
rm $input_dir/${basename}_int.tsv 
rm $input_dir/${basename}_outlier_postprocessed.tsv
echo "completed $basename"
done
