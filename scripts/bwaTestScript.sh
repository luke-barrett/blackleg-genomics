#!/bin/bash
#SBATCH --job-name=bwa_test
#SBATCH --time=00:45:00
#SBATCH --ntasks=1
#SBATCH --mem=2g

module load bwa

echo "module has loaded"

####hard code in directory, metadata and genome information. This is now entered via seperate script './ BWAscriptVariables.sh'
  

#OUT_DIR="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test"
#IN_DIR="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test"
#METADATA="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/TESTmetaData.txt"
#GENOME="/OSM/CBR/AF_DATASCHOOL/input/2018-04-23_Lmaculans/analyses/bwa/test/GCF_000230375.1_ASM23037v1_genomic.fna"

###############################################################################################################################
# IN_LIST takes unique identifiers from first column of metadata (barcode etc), removes the R1/R2 tag (to analyse F&R reads 
# together), and sorts unique to take just one copy of this 
# i.e. prints the METADATA file minus the first lines| cuts the first column | replaces _R1 or _R2 and identifiers with nothing, 
# so, IN_List combines each pair of files (R1 and R2) and we then call this STEM
###############################################################################################################################

IN_LIST=( $(tail -n +2 ${METADATA} | cut -f 1 | sed "s/_R[12].*//" | sed 's/^"//' | sort -u) );


#### echo here writes IN_LIST to log file for testing. now commented out
echo ${IN_LIST[$SLURM_ARRAY_TASK_ID]} >> ${OUT_DIR}/outputTest.log

#exit 1 #will stop script here for testing purposes

####################################################################################
## script below will construct @RG header than run bwa for each pair of fastq files
####################################################################################

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
            STEM=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
	    SAMPLE=`grep "${STEM}" $METADATA | cut -f3 | sed -e 's/^"//' -e 's/"$//' | sort -u` # sampleName 
            DATE=`grep "${STEM}" $METADATA | cut -f13 | sed -e 's/^"//' -e 's/"$//' | sort -u` # date column 12 metadata
            PLATFORM=`grep "${STEM}" $METADATA | cut -f14 | sed -e 's/^"//' -e 's/"$//' | sort -u` # column 13 metadata
            LIBRARY="${SAMPLE}.${ID}.${DATE}" # join data to create new sample info
            CENTRE=`grep "${STEM}" $METADATA | cut -f11 | sed -e 's/^"//' -e 's/"$//' | sort -u` # seq centre column 10
            BARCODE=`grep "${STEM}" $METADATA | cut -f2 | sed -e 's/^"//' -e 's/"$//' | sort -u`
            LANE=`grep "${STEM}" $METADATA | cut -f10 | sed -e 's/^"//' -e 's/"$//' | sort -u` # seq lane column 9`
	    UNIT=`grep "${STEM}" $METADATA | cut -f4 | sed -e 's/^"//' -e 's/"$//' | sort -u` #aka flowcell
	    P_UNIT="${UNIT}.${LANE}" # join data to to create platform unit variable
	    ID="${BARCODE}.${P_UNIT}" #unique ID
            RG=`echo "@RG\tID:${ID}\tBC:${BARCODE}\tCN:${CENTRE}\tDT:${DATE}\tLB:${LIBRARY}\tPL:${PLATFORM}\tPU:${P_UNIT}\tSM:${SAMPLE}"`
	    echo CMD: bwa mem -M -R ${RG} ${GENOME} ${IN_DIR}/${STEM}*fastq.gz >> $OUT_DIR/${STEM}.log #write bwa command to log
            if [ ! -f ${OUT_DIR}/${STEM}.sam ]
            then 
                bwa mem -M -R ${RG} ${GENOME} ${IN_DIR}/${STEM}*fastq.gz > ${OUT_DIR}/${STEM}.sam 2>> $OUT_DIR/${STEM}.log
            fi
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi
