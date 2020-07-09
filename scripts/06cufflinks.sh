#!/bin/bash

module load cufflinks

line=$1
strand=$2
bam=${line}_sorted.bam

cufflinks \
   --output-dir ${line} \
   --num-threads 16 \
   --library-type ${strand} \
   --verbose \
   --no-update-check \
   $bam
