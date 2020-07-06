#!/bin/bash


line=$1
out=/tmp/out_${line}

# Zm_B73.bed is the gene model download from maize GDB in bed format. 
infer_experiment.py -r Zm_B73.bed -i ${line}_sorted.bam -s 2000000 > ${out}
A=$(grep "1++,1--,2+-,2-+" ${out} | cut -f2 -d":")
B=$(grep "1+-,1-+,2++,2--" ${out} | cut -f2 -d":")
ratio=$(awk '{print $1/$2}' <<<"${A} ${B}")

if [ $(echo "${ratio} > 2" | bc -l) -eq 1 ]; then
   echo "${line} --fr ${ratio} ${A} ${B}"
elif [ $(echo "${ratio} < 0.5" | bc -l) -eq 1 ]; then
   echo "${line} --rf ${ratio} ${A} ${B}"
else
   echo "${line} non-strandeness ${ratio} ${A} ${B}"
fi
