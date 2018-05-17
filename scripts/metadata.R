library(tidyverse)

####################################################
##1. Read in sample file names from sequencing runs
## Two x paired end reads across two runs

seqFile1<-read_csv(file = "metadata/1820Name_file.txt", col_names = FALSE)
seqFile2<-read_csv(file = "metadata/1821Name_file.txt", col_names = FALSE)
colnames(seqFile1)<-"file.name"; colnames(seqFile2)<-"file.name"

####rename unidentified null files (will delete them later)
seqFile1[770,]<-"1820_NA-NA_S0_L004_R1_001.fastq.gz"
seqFile1[771,]<-"1820_NA-NA_S0_L004_R2_001.fastq.gz"

seqFile2[770,]<-"1821_NA-NA_S0_L004_R1_001.fastq.gz"
seqFile2[771,]<-"1821_NA-NA_S0_L004_R2_001.fastq.gz"

###wrangle the sequence metadata into shape for metafile using Loops to process seperate seqFiles

sF.list<-list(seqFile1, seqFile2)

fileList<-list()

for(i in 1:length(sF.list)){
  fileList[[i]]<-sF.list[[i]] %>% 
    filter(grepl("182._",file.name)) %>%
    separate(file.name, 
             c("run", "barcodeL", "barcodeR", "sNum", "lane","read","runread","ext1","ext2")) %>% 
    mutate(run=as.integer(run)) %>% 
    mutate(Lane=substr(lane,4,4)) %>% 
    mutate(barcode=paste(barcodeL, barcodeR, sep="-")) %>% 
    mutate(ID=paste(run,barcode,sNum, lane, read, sep="_")) %>% 
    select(-lane) %>% 
    mutate(CN="snpsaurus")
}

metList<-list()

for(i in 1:length(fileList)){
  metList[[i]]<-fileList[[i]] %>% 
    separate(sNum, c("junk", "seqNo"), sep=1) %>% 
    select(-junk) %>% 
    mutate(seqNo=as.integer(seqNo)) %>% 
    arrange(seqNo) %>% 
    mutate(sampleNo=rep(0:384, each=2)) %>% 
    mutate(date="2018-04-11") %>% 
    mutate(platform="Illumina") 
}

#####generate single dataframe for all sequence files

metA<-rbind(metList[[1]], metList[[2]])
tail(metA)

#############################################
##read in snpsaurus key

key<-read_csv("metadata/maculansKey.csv")

keyDat<-key %>% 
  separate(barcode, c("barcodeL", "barcodeR") )

############################################
###merge key and file names

returnedDat<-metA %>%
  left_join(keyDat, by=c("barcodeL", "barcodeR", "run")) %>% 
  select(-ext1, -ext2, -runread) %>% 
  #mutate(seqNo=as.integer(seqNo)) %>% 
  arrange(seqNo)

################################################
##read in sample info

sampleDat<-read_csv("metadata/sampleData.csv")

################################################
##merge returned names and sample names and write metafile

metaDat<-returnedDat %>% 
  left_join(sampleDat, by="sampleNo") %>% 
  filter(barcodeL!="NA") %>%  ##remove unknown sequence files
  select(-sample_name)

refcols <- c("ID", "barcode", "sampleName")
metaDat<- metaDat[, c(refcols, setdiff(names(metaDat), refcols))]

#write.table(metaDat, file = "metaData.txt", sep="\t", row.names = FALSE)

#########
#subset metaDat for test dataset (all A-01 reps)

testMeta<-metaDat %>% 
  filter(sampleName=="A-01")

write.table(testMeta, file = "TESTmetaData.txt", sep="\t", row.names = FALSE)
