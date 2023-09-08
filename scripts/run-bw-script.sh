#!/bin/bash

input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo

#use this script to annotate ehdn result files

ls $input_dir | grep 'tsv' | while read -r line ; do

python3 $working_dir/scripts/annotate_EHdn_locus_outliers.py \
--reference-tr-bed-file $working_dir/refs/Homo_sapiens_assembly38.trf_period1-6.dedup.sorted.bed \
--known-disease-associated-loci $working_dir/refs/variant_catalogs/variant_catalog_without_offtargets.GRCh38.json \
-o $input_dir/postprocess/ \
--verbose \
${input_dir}/${line} 
done