#!/bin/sh
#expansion hunter de novo case-control analysis
input_dir=$1 #path to input directory

ls $input_dir | grep 'cram\|bam' | grep -v 'crai\|bai' | while read -r line ; do
    basename=${line%%.*} 

echo "Compute locus CC analysis for ${basename}"
/data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/casecontrol.py locus \
        --manifest /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/manifests/$basename.manifest.tsv \
        --multisample-profile /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/str-profiles/merged/$basename.multisample_profile.json \
        --output /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/$basename.CC_locus.tsv

echo "Compute motif CC analysis for ${basename}"
/data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/scripts/casecontrol.py motif \
        --manifest /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/manifests/$basename.manifest.tsv \
        --multisample-profile /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/str-profiles/merged/$basename.multisample_profile.json \
        --output /data/ExpansionHunterDenovo-v0.9.0-linux_x86_64/results/$basename.CC_motif.tsv
done