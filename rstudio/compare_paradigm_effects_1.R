library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "brain_topo_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

spec_test  <- data.frame(SUB=character(), GROUP=character())
list_suj   <- unique(pat$SUB)

for (sb in 1:length(list_suj)){
  
  suj  = list_suj[sb]
  
  vcue = mean(pat[pat$SUB==suj & pat$cond_dis=='DIS0' & pat$cond_cue=='Valid',"MedianRT"])
  ncue = mean(pat[pat$SUB==suj & pat$cond_dis=='DIS0' & pat$cond_cue=='Neutral',"MedianRT"])
  
  dnon =  mean(pat[pat$SUB==suj & pat$cond_dis=='DIS0',"MedianRT"])
  dear =  mean(pat[pat$SUB==suj & pat$cond_dis=='DIS1',"MedianRT"])
  dlat =  mean(pat[pat$SUB==suj & pat$cond_dis=='DIS3',"MedianRT"])
  
  # e_td = (ncue-vcue)/vcue
  # e_ar = (dnon-dear)/dear
  # e_cp = (dlat-dear)/dear
  
  v = (ncue-vcue)
  bloc <- cbind(suj,'cat1','TD',v);  spec_test<-rbind(spec_test,bloc)
  
  v = (dnon-dear)
  bloc <- cbind(suj,'cat1','arousal',v);  spec_test<-rbind(spec_test,bloc)
  
  v = (dlat-dear)
  bloc <- cbind(suj,'cat1','capture',v);  spec_test<-rbind(spec_test,bloc)

  
}

rm(list=setdiff(ls(), "spec_test"))

pat = read.table("/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/Old/Old/PrepAtt2.medianRT.txt",header=T)

list_suj   <- unique(pat$SUB)

for (sb in 1:length(list_suj)){
  
  suj  = list_suj[sb]
  
  vcue = mean(pat[pat$SUB==suj & pat$DIS=='D0' & pat$CUE !='N',"medianRT"])
  ncue = mean(pat[pat$SUB==suj & pat$DIS=='D0' & pat$CUE =='N',"medianRT"])
  
  dnon =  mean(pat[pat$SUB==suj & pat$DIS=='D0',"medianRT"])
  dear =  mean(pat[pat$SUB==suj & pat$DIS=='D1',"medianRT"])
  dlat =  mean(pat[pat$SUB==suj & pat$DIS=='D3',"medianRT"])
  
  v = (ncue-vcue)
  bloc <- cbind(suj,'cat2','TD',v);  spec_test<-rbind(spec_test,bloc)
  
  v = (dnon-dear)
  bloc <- cbind(suj,'cat2','arousal',v);  spec_test<-rbind(spec_test,bloc)
  
  v = (dlat-dear)
  bloc <- cbind(suj,'cat2','capture',v);  spec_test<-rbind(spec_test,bloc)
  
}

rm(list=setdiff(ls(), "spec_test"))

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "allyoungcontrol_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

list_suj   <- unique(pat$SUB)

for (sb in 1:length(list_suj)){
  
  suj  = list_suj[sb]
  
  vcue = mean(pat[pat$SUB==suj & pat$DIS=='D0' & pat$CUE_CAT =='informative',"MedianRT"])
  ncue = mean(pat[pat$SUB==suj & pat$DIS=='D0' & pat$CUE_CAT =='uninformative',"MedianRT"])
  
  dnon =  mean(pat[pat$SUB==suj & pat$DIS=='D0',"MedianRT"])
  dear =  mean(pat[pat$SUB==suj & pat$DIS=='D1',"MedianRT"])
  dlat =  mean(pat[pat$SUB==suj & pat$DIS=='D2',"MedianRT"])
  
  v = (ncue-vcue)
  bloc <- cbind(suj,'cat3','TD',v);  spec_test<-rbind(spec_test,bloc)
  
  v = (dnon-dear)
  bloc <- cbind(suj,'cat3','arousal',v);  spec_test<-rbind(spec_test,bloc)
  
  v = (dlat-dear)
  bloc <- cbind(suj,'cat3','capture',v);  spec_test<-rbind(spec_test,bloc)
  
}

rm(list=setdiff(ls(), "spec_test"))

names(spec_test) <- c("SUB","EXPE","effect","value")

spec_test$value <- as.numeric(levels(spec_test$value))[spec_test$value]

spec_test$SUB = factor(spec_test$SUB)
spec_test$EXPE = factor(spec_test$EXPE)
spec_test$effect = factor(spec_test$effect)

pd <- position_dodge(0.1) # move them .05 to the left and right
pat <- spec_test[spec_test$effect=="TD",]

tgc <- summarySE(pat, measurevar="value", groupvars=c("EXPE"))

p1 <- ggplot(tgc, aes(x=EXPE, y=value)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3)+ylim(0,80)+theme_classic()

pat <- spec_test[spec_test$effect=="arousal",]
tgc <- summarySE(pat, measurevar="value", groupvars=c("EXPE"))

p2 <- ggplot(tgc, aes(x=EXPE, y=value)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3)+ylim(0,80)+theme_classic()

pat <- spec_test[spec_test$effect=="capture",]
tgc <- summarySE(pat, measurevar="value", groupvars=c("EXPE"))

p3 <- ggplot(tgc, aes(x=EXPE, y=value)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3)+ylim(0,80)+theme_classic()

ggarrange(p1,p2,p3,ncol = 3, nrow = 1,labels = c("TD","arousal","capture"))


## check CAT3.0 cue benefit
pat = spec_test[spec_test$EXPE=="cat3" & spec_test$effect=="TD",]

t.test(spec_test$value, mu=0, alternative = "two.sided")
