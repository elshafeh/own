library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)

rm(list=ls())

#fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_Allparticipants_behav_table4R_withTukey.csv"
#fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_Allparticipants_behav_table4R_withTukey.csv"
fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R_withTukey.csv"

behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)

names_group=c("old","young",'migraine','patient','control')
if (length(list_grp)==4){names_group=c("old","young",'patient','control')}

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=numeric(), p_miss =numeric(),
                         p_falseAlarm = numeric(),stringsAsFactors=TRUE)
for (gr in 1:length(list_grp)){
  
  pat <- behav_summary[behav_summary$idx_group == list_grp[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    for (cue in 1:2){
      for (dis in 1:3){
        
        #if (cue>2){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-2 & pat$DIS==dis-1,]}
        #if (cue==1){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$TAR%%2 != 0 & pat$DIS==dis-1,]}
        #if (cue==2){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$TAR%%2 == 0 &pat$DIS==dis-1,]}
        
        if (cue==1){sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE!=0 & pat$DIS==dis-1,]}
        if (cue==2){sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$DIS==dis-1,]}
        
        #sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-1 &pat$DIS==dis-1,]
        
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
        medianRT_tukey = median(sub_pat[sub_pat$CORR==1,11])
        
        bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],p_incorrect,p_miss,p_fa,medianRT,medianRT_tukey)
        
        pat_concat<-rbind(pat_concat,bloc)
        
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))
pat_concat[,10] <-paste(as.character(pat_concat[,3]),as.character(pat_concat[,2]),sep="-")

names(pat_concat) <- c("SUB","GROUP","CUE","DIS","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT","MedianRTukey","NewCode")

pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]
pat_concat$MedianRT <- as.numeric(levels(pat_concat$MedianRT))[pat_concat$MedianRT]
pat_concat$MedianRTukey <- as.numeric(levels(pat_concat$MedianRTukey))[pat_concat$MedianRTukey]

pat_concat$NewCode <- factor(pat_concat$NewCode)

pat_age <- pat_concat[pat_concat$GROUP=="old" | pat_concat$GROUP=="young",]
pat_age$SUB <- factor(pat_age$SUB)
pat_age$GROUP <- factor(pat_age$GROUP)
pat_age$NewCode <- factor(pat_age$NewCode)

a <- ezANOVA(pat_age,dv=.(MedianRTukey),wid = .(SUB),within = .(CUE,DIS),between = (GROUP),detailed=T)
print(a)

interaction.ABC.plot(MedianRTukey, x.factor=DIS,
                     groups.factor=CUE, trace.factor=GROUP,
                     data=pat_age)
              
tgc <- summarySE(pat_age, measurevar="MedianRTukey", groupvars=c("NewCode","DIS"))

# The errorbars overlapped, so use position_dodge to move them horizontally
#pd <- position_dodge(0) # move them .05 to the left and right

#ggplot(tgc, aes(x=DIS, y=MedianRTukey, colour=NewCode)) + 
 # geom_errorbar(aes(ymin=MedianRTukey-se, ymax=MedianRTukey+se), width=.1, position=pd,group = 1) +
#  geom_line(position=pd,group = 1) +
#  geom_point(position=pd)