#----------------------analysis variables------------------------#

#!/bin/bash

####hard code in directory, metadata and genome information. This maybe should be run from the command line or a different

export OUT_DIR="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/bwa_out"
export IN_DIR="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test"
export METADATA="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/TESTmetaData.txt"
export GENOME="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/GCF_000230375.1_ASM23037v1_genomic.fna"

#### NUM is for number of array jobs in array job call
NUM_meta=`expr $(wc -l $METADATA | cut -d" " -f1) - 2`
echo $NUM_meta
NUM_reads=2
NUM=`echo $((NUM_meta / NUM_reads))`

#########################################################
#to run: sbatch -a 0-$NUM bwaTestScript.sh
