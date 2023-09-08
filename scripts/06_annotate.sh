#!/bin/bash

input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo

#use this script to annotate ehdn result files

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*} 

echo "Annotate results for ${basename}"

bash $working_dir/scripts/annotate_ehdn.sh \
    --ehdn-results $working_dir/results/${basename}.outlier_locus.tsv \
    --ehdn-annotated-results $working_dir/results/${basename}.outlier_locus.annotated.tsv \
    --annovar-annotate-variation /data/annovar/annotate_variation.pl \
    --annovar-humandb /data/annovar/humandb \
    --annovar-buildver hg38

bash $working_dir/scripts/annotate_ehdn.sh \
    --ehdn-results $working_dir/results/${basename}.CC_locus.tsv \
    --ehdn-annotated-results $working_dir/results/${basename}.CC_locus.annotated.tsv \
    --annovar-annotate-variation /data/annovar/annotate_variation.pl \
    --annovar-humandb /data/annovar/humandb \
    --annovar-buildver hg38    

(head -n1 $working_dir/results/${basename}.CC_locus.annotated.tsv && tail -n +2 $working_dir/results/${basename}.CC_locus.annotated.tsv | sort -k7 ) > $working_dir/results/${basename}.CC_locus.annotated.sorted.tsv
(head -n1 $working_dir/results/${basename}.outlier_locus.annotated.tsv && tail -n +2 $working_dir/results/${basename}.outlier_locus.annotated.tsv | sort -k7 -r ) > $working_dir/results/${basename}.outlier_locus.annotated.sorted.tsv

done