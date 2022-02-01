#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=96
#SVATCH --partition=biocrunch
#SBATCH -t 96:00:00
#SBATCH -J portcullis
#SBATCH -o portcullis.o%j
#SBATCH -e portcullis.e%j


module load singularity
singularity exec /path/to/portcullis_stable.sif portcullis full --threads 96 --verbose --use_csi --output portcullis_out Zm-B73-REFERENCE-NAM-5.0.fa merged_sorted.bam

