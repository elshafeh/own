library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)

rm(list=ls())
names_group=c("old","young","patient","control")

fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R.csv"
behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=character(), p_miss =character(),
                         p_falseAlarm = character(),stringsAsFactors=TRUE)

for (gr in 1:length(list_grp)){
  
  pat <- behav_summary[behav_summary$idx_group == list_grp[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    for (cue in 1:3){
      for (dis in 1:3){
        
        sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-1 & pat$DIS==dis-1,]
        neutral_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$DIS==dis-1,]
        
        suj <- paste0(names_group[gr],sb)
        
        cue_names = c('NCue','LCue','RCue')
        dis_names = c('D0','D1','D2')
        
        medianRT = median(sub_pat[sub_pat$CORR==1,11])
        neutrRT <- median(neutral_pat[neutral_pat$CORR==1,11])
        
        rlchange <- (medianRT-neutrRT)/neutrRT
        
        bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],rlchange)
        
        pat_concat<-rbind(pat_concat,bloc)
        
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))

names(pat_concat) <- c("SUB","GROUP","CUE","DIS","RelChangeRT")

pat_concat$SUB <- factor(pat_concat$SUB)
pat_concat$CUE <- factor(pat_concat$CUE)
pat_concat$DIS <- factor(pat_concat$DIS)
pat_concat$RelChangeRT <- as.numeric(levels(pat_concat$RelChangeRT))[pat_concat$RelChangeRT]

pat_concat <- pat_concat[pat_concat$CUE != "NCue",]
pat_concat$CUE <- factor(pat_concat$CUE)

pat_age <- pat_concat[pat_concat$GROUP=="old" | pat_concat$GROUP=="young",]
pat_age$SUB <- factor(pat_age$SUB)
pat_age$GROUP <- factor(pat_age$GROUP)

pat_avc <- pat_concat[pat_concat$GROUP=="patient" | pat_concat$GROUP=="control",]
pat_avc$SUB <- factor(pat_avc$SUB)
pat_avc$GROUP <- factor(pat_avc$GROUP)


a <- ezANOVA(pat_avc,dv=.(RelChangeRT),wid = .(SUB),within = .(CUE,DIS),between = (GROUP),detailed=T)
print(a)

