#!/bin/bash

module load hmmer
module load parallel

#install path for KofamScan
folder=/work/LAS/mash-lab/jing/bin/kofam_scan
query=B73
${folder}/exec_annotation -o ${query}.txt -k ${folder}/ko_list -p ${folder}/profiles --cpu=64 -E 0.001 -f detail-tsv --tmp-dir ${query}_tmp ${query}.faa
