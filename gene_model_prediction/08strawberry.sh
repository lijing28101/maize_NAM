#!/bin/bash

module load samtools

line=$1
#specific strand from strand_info.txt. Put a space here if the libary is a nonstranded library.
strand=$2
bam=${line}_sorted.bam

singularity exec ${bin}/strawberry_v1.1.1.sif  /home/strawberry/bin/strawberry \
  ${bam} \
  ${strand} \
  -o ${line}_strawberry.gtf \
  -p 16 \
  --verbose 
