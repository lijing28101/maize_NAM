#!/bin/bash

module load samtools
module load hisat2

# build hisat2 inddex, only need once.
# hisat2-build Zm-B73-REFERENCE-NAM-5.0.fa Zm_B73
# define index build by last step.
index=Zm_B73
line=$1
R1=${line}_1.clean.fastq.gz
R2=${line}_2.clean.fastq.gz

# change the threads number according your system.
hisat2 -p 16 -x ${index} --dta-cufflinks -1 $R1 -2 $R2 -S ${line}.sam
samtools view -@ 16 -b -o ${line}.bam ${line}.sam
samtools sort -o ${line}_sorted.bam -T ${line}_temp --threads 16 ${line}.bam
rm -rf ${line}.sam ${line}.bam
