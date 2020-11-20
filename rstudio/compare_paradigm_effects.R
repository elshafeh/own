library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())
pd <- position_dodge(0.1) # move them .05 to the left and right

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
  
  e_td = (ncue-vcue)
  e_ar = (dnon-dear)
  e_cp = (dlat-dear)
  
  bloc <- cbind(suj,'cat1',e_td,e_ar,e_cp)
  
  spec_test<-rbind(spec_test,bloc)
  
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
  
  e_td = (ncue-vcue)
  e_ar = (dnon-dear)
  e_cp = (dlat-dear)
  
  bloc <- cbind(suj,'cat2',e_td,e_ar,e_cp)
  
  spec_test<-rbind(spec_test,bloc)
  
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
  
  e_td = (ncue-vcue)
  e_ar = (dnon-dear)
  e_cp = (dlat-dear)
  
  bloc <- cbind(suj,'cat3',e_td,e_ar,e_cp)
  
  
  spec_test<-rbind(spec_test,bloc)
  
}

rm(list=setdiff(ls(), "spec_test"))

names(spec_test) <- c("SUB","EXPE","TD","Arousal","Capture")

spec_test$TD <- as.numeric(levels(spec_test$TD))[spec_test$TD]
spec_test$Arousal <- as.numeric(levels(spec_test$Arousal))[spec_test$Arousal]
spec_test$Capture <- as.numeric(levels(spec_test$Capture))[spec_test$Capture]

spec_test$SUB = factor(spec_test$SUB)
spec_test$EXPE = factor(spec_test$EXPE)

p1 = ggplot(spec_test, aes(x=EXPE, y=TD, fill=EXPE)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=4, color="red", fill="red") +
  theme(legend.position="none") + ylim(-150,150)+theme_classic()

p2 = ggplot(spec_test, aes(x=EXPE, y=Arousal, fill=EXPE)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=4, color="red", fill="red") +
  theme(legend.position="none") + ylim(-150,150)+theme_classic()

p3 = ggplot(spec_test, aes(x=EXPE, y=Capture, fill=EXPE)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=4, color="red", fill="red") +
  theme(legend.position="none") + ylim(-150,150)+theme_classic()

ggarrange(p1, p2,p3,ncol = 3, nrow = 1)

# ggplot(tgc, aes(x=DIS, y=MedianRT, colour=CUE_CAT, group=CUE_CAT)) + 
#   geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), colour="black", width=.1, position=pd) +
#   geom_line(position=pd) +
#   geom_point(position=pd, size=3)+ylim(450,600)+theme_classic()