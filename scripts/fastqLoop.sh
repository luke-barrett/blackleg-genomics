#!/bin/bash
#SBATCH --job-name=run_fastqc
#SBATCH --time=05:05:00
#SBATCH --ntasks=5
#SBATCH --mem=5g
module load fastqc

echo "$SLURM_NTASKS to the core"

for i in *.fastq.gz
do
        fastqc $i
done
