library(tidyverse)
sDat<-read_csv(file = "metadata/samples_sent_for_seq.csv")

head(sDat)
tail(sDat)
sampleDat<-sDat %>% 
  gather(Column,sampleName, -ID, -PLATE,-Row) 

sampleDat2<-sampleDat %>% 
  spread(ID, sampleName)
sampleDat2<-sampleDat2[c(5,1,3,2,4)]

sampleDatbyRow<-sampleDat2 %>% 
  separate(Column, c("junk", "Column"), sep=1) %>% 
  select(-junk) %>% 
  mutate(Column=as.integer(Column)) %>% 
  arrange(PLATE, Row, Column) %>% 
  mutate(seqNo=seq(1,384, 1)) %>% 
  mutate(seqNo=as.integer(seqNo))


head(sampleDatbyRow)
tail(sampleDatbyRow)

write.csv(sampleDatbyRow, "metaDat2.csv")
