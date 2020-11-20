library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)

rm(list=ls())
names_group=c("old","young","patient","control")
fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_hesham_table4R_withTukey_withSpeedCategory.csv"
behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=numeric(), p_miss =numeric(),
                         p_falseAlarm = numeric(),stringsAsFactors=TRUE)

for (gr in 1:length(list_grp)){
  
  pat <- behav_summary[behav_summary$idx_group == list_grp[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    for (cue in 1:2){
      for (dis in 1:3){
        
        if (cue==1){sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE!=0 & pat$DIS==dis-1,]}
        if (cue==2){sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$DIS==dis-1,]}
        
        #sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-1 & pat$DIS==dis-1,]
        
        suj <- paste0(names_group[gr],sb)
        
        n_incorrect <- lengths(sub_pat[sub_pat$CORR==-1,])[1]
        n_miss <- lengths(sub_pat[sub_pat$ERROR==1,])[1]
        n_fa <- lengths(sub_pat[sub_pat$ERROR==3,])[1]
        n_tot <- lengths(sub_pat)[1]
        
        p_incorrect <- (n_incorrect/n_tot)*100
        p_miss <- (n_miss/n_tot)*100
        p_fa <- (n_fa/n_tot)*100
        
        cue_names = c('Inf','Unf')
        #cue_names = c('NCue','LCue','RCue')
        dis_names = c('D0','D1','D2')
        
        medianRT = median(sub_pat[sub_pat$CORR>0,11])
        xi <- sub_pat$Speed[1]
          
        bloc <- cbind(suj,names_group[gr],as.character(sub_pat$Speed[1]),cue_names[cue],dis_names[dis],p_incorrect,p_miss,p_fa,medianRT)
        
        pat_concat<-rbind(pat_concat,bloc)
        
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))
names(pat_concat) <- c("SUB","GROUP","SPEED_CAT","CUE","DIS","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT")

pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]
pat_concat$MedianRT <- as.numeric(levels(pat_concat$MedianRT))[pat_concat$MedianRT]

names_group=c("old","young","patient","control")

for (gr in 1:length(names_group)){
  
  test_pat <- pat_concat[pat_concat$GROUP == names_group[gr],]
  test_pat$SUB <- factor(test_pat$SUB)
  test_pat$GROUP <- factor(test_pat$GROUP)
  
  a <- ezANOVA(test_pat,dv=.(MedianRT),wid = .(SUB),within = .(CUE,DIS),between=(SPEED_CAT),detailed=T)
  print(a)
  
}