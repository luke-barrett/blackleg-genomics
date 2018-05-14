#!/bin/bash
#SBATCH --job-name=run_fastqc
#SBATCH --time=02:10:00
#SBATCH --ntasks-per-node=5
#SBATCH --mem=5g
module load fastqc
if [ -d "$INDIR" ]
then
     INFILES=( `ls -1 ${INDIR}/*.fastq.gz` )
    if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        i=$SLURM_ARRAY_TASK_ID
        fastqc ${INFILES[$i]}
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
    fi
else
    echo "Error: Missing input file directory as --export env INDIR or doesn't exist"
fi
