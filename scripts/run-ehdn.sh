#!/bin/sh

#define variable
ref=/data/references/Homo_sapiens_assembly38.fasta #path to reference sequence
input_dir=$1 #path to input directory
working_dir=/data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/

#start while loop
ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
basename=${line%%.*} 

# 1) generate manifest
    echo "Generate manifest for ${basename}"
    cp $working_dir/manifests/manifest.tsv $working_dir/manifests/$basename.manifest.tsv
    sed -i 's|basename|'$basename'|g' $working_dir/manifests/$basename.manifest.tsv &&

# 2) compute str-profile from all files in input directory
    echo "Profiling ${basename}"
    ExpansionHunterDenovo profile \
        --reads $input_dir/$line \
        --reference $ref \
        --output-prefix $working_dir/str-profiles/$basename \
        --min-anchor-mapq 50 \
        --max-irr-mapq 40 &&

# 3) merge str profiles computed using Expansion Hunter Denovo
    echo "Merging ${basename}" 
    ExpansionHunterDenovo merge \
        --reference $ref \
        --manifest $working_dir/manifests/$basename.manifest.tsv \
        --output-prefix $working_dir/str-profiles/merged/$basename && 

# 4) expansion hunter de novo outlier and cc analysis
echo "Compute locus outliers for ${basename}"
/data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/outlier.py locus \
        --manifest $working_dir/manifests/$basename.manifest.tsv \
        --multisample-profile $working_dir/str-profiles/merged/$basename.multisample_profile.json \
        --output $working_dir/results/outlier/$basename.outlier_locus.tsv &&

echo "Compute locus CC analysis for ${basename}"
/data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/casecontrol.py locus \
        --manifest $working_dir/manifests/$basename.manifest.tsv \
        --multisample-profile $working_dir/str-profiles/merged/$basename.multisample_profile.json \
        --output $working_dir/results/cc/$basename.CC_locus.tsv &&

# 5) annotate outlier and cc analysis
echo "Annotate results for ${basename}"

bash $working_dir/scripts/annotate_ehdn.sh \
    --ehdn-results $working_dir/results/outlier/${basename}.outlier_locus.tsv \
    --ehdn-annotated-results $working_dir/results/outlier/${basename}.outlier_locus.annotated.tsv \
    --annovar-annotate-variation /data/annovar/annotate_variation.pl \
    --annovar-humandb /data/annovar/humandb \
    --annovar-buildver hg38

bash $working_dir/scripts/annotate_ehdn.sh \
    --ehdn-results /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/cc/${basename}.CC_locus.tsv \
    --ehdn-annotated-results /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/cc/${basename}.CC_locus.annotated.tsv \
    --annovar-annotate-variation /data/annovar/annotate_variation.pl \
    --annovar-humandb /data/annovar/humandb \
    --annovar-buildver hg38 ;

done