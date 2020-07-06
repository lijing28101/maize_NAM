#!/bin/bash

# define the installed folder for bbduk
bbmap_folder=/home/jingli/bbmap/
# define the adapter sequence database. 
# BBDuk install with a default database , you can also add your own adapter sequence in the file.
bbduk_ref=${bbmap_folder}/resources/adapters.fa

line=$1

#delete adapter sequence and quality triming
${bbmap_folder}/bbduk.sh in1=${line}_1.fastq.gz in2=${line}_2.fastq.gz out1=${line}_1.clean.fastq.gz out2=${line}_2.clean.fastq.gz ref=${bbduk_ref} ktrim=r k=23 mink=11 hdist=1 qtrim=rl trimq=10
echo "Remove adapter successful" "${line}"
