#!/bin/bash

#SBATCH -N 1
#SBATCH --cpus-per-task=48
#SBATCH --mem=500GB
#SBATCH -t 150:00:00
#SBATCH -J braker
#SBATCH -o braker.o%j
#SBATCH -e braker.e%j

# To activate conda environment in a submitted job
source /path/to/Anaconda3/etc/profile.d/conda.sh
source ~/.bashrc
conda activate mypy3.5

module load genemark-et/4.38-63ipkx4
module load augustus/3.3.2-py3-openmpi3-gee2bjt
module load bamtools/2.5.1-mgm42ro
module load samtools/1.9-k6deoga
module load ncbi-rmblastn/2.2.28-t52d4vp
module rm perl

# export editable augustus path
export AUGUSTUS_CONFIG_PATH=/path/to/augustus/config
export AUGUSTUS_BIN_PATH=/path/to/bin/augustus/bin
export AUGUSTUS_SCRIPTS_PATH=/path/to/augustus/scripts

# Change the species name and genome for different lines
braker.pl --cores=48 \
--overwrite \
--species=maize_B73 \
--genome=Zm-B73-REFERENCE-NAM-5.0.fa \
--bam=merged_sorted.bam \
--gff3
