INDIR="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test"
METADATA="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/TESTmetaData.txt
GENOME="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/GCF_000230375.1_ASM23037v1_genomic.fna"
NUM=`expr $(wc -l $METADATA | cut -d" " -f1) - 1`
sbatch -a 0-$NUM --export GENOME="$GENOME" METADATA="$METADATA" INDIR="$INDIR" LC_BWA_alignment_v2.sh


