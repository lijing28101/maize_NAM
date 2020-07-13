#!/bin/bash

module load cufflinks

line=$1
#specific strand from strand_info.txt. Use fr-firststrand instead of --rf, fr-secondstrand instead of --fr, fr-unstranded instead of non-strandeness.
strand=$2
bam=${line}_sorted.bam

cufflinks \
   --output-dir ${line} \
   --num-threads 16 \
   --library-type ${strand} \
   --verbose \
   --no-update-check \
   $bam
