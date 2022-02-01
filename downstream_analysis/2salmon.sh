#!/bin/bash

srr=$1

salmon quant -i salmon_index -l A -1 ${srr}_R1.fq.gz -2 ${srr}_R2.fq.gz --validateMappings --gcBias -p 96 -o ${srr}
