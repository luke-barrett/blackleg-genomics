# to run fastqc batch script from command line
INDIR="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/rawData"
NUM=$(expr $(ls -1 ${INDIR}/*.fastq.gz | wc -l) - 1)
sbatch -a 0-$NUM --export INDIR="$INDIR" batch_fastqc.sh

