#!/bin/bash

module load bamtools

# List all SRR ID in SRR_list.txt, one ID per line.
bamtools merge -list SRR_list.txt -out merged_sorted.bam
