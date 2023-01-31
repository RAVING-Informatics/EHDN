#!/bin/bash

input_dir=$1 #path to input directory

#use this script to annotate ehdn result files

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*} 

echo "Annotate results for ${basename}"

bash /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/annotate_ehdn.sh \
    --ehdn-results /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.outlier_locus.tsv \
    --ehdn-annotated-results /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.outlier_locus.annotated.tsv \
    --annovar-annotate-variation /data/annovar/annotate_variation.pl \
    --annovar-humandb /data/annovar/humandb \
    --annovar-buildver hg38

bash /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/annotate_ehdn.sh \
    --ehdn-results /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.CC_locus.tsv \
    --ehdn-annotated-results /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.CC_locus.annotated.tsv \
    --annovar-annotate-variation /data/annovar/annotate_variation.pl \
    --annovar-humandb /data/annovar/humandb \
    --annovar-buildver hg38    

(head -n1 /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.CC_locus.annotated.tsv && tail -n +2 /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.CC_locus.annotated.tsv | sort -k7 ) > /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.CC_locus.annotated.sorted.tsv
(head -n1 /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.outlier_locus.annotated.tsv && tail -n +2 /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.outlier_locus.annotated.tsv | sort -k7 -r ) > /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/${basename}.outlier_locus.annotated.sorted.tsv

done