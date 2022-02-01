#!/bin/bash

module load trinity

line=$1
#specific strand from strand_info.txt. Use RF instead of --rf, FR instead of --fr. The default option is non-strandeness, no --SS_lib_type is non-strandeness.
strand=$2
bam=${line}_sorted.bam

Trinity \
   --genome_guided_bam ${bam} \
   --SS_lib_type ${strand} \
   --max_memory 110G \
   --genome_guided_max_intron 10000 \
   --full_cleanup \
   --CPU 16 \
   --output ${line}_trinity
   
