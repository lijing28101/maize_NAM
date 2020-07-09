#!/bin/bash
  
module load samtools 

line=$1
strand=$2
bam=${line}_sorted.bam

perl ${CLASS2_HOME}/run_class.pl \
  -a ${bam} \
  -o ${line}_class.gtf \
  -p 16 \
  --verbose \
  --clean
