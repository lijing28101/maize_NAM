#!/bin/bash
module load stringtie

line=$1
#specific strand from strand_info.txt. Put a space here if the libary is a nonstranded library.
strand=$2
bam={line}_sorted.bam

stringtie \
   ${bam} \
   ${strand} \
   -p 16 \
   -v \
   -o ${line}_cufflinks.gtf
