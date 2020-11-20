library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)

rm(list=ls())
fname = "/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/R/txt/PrepAtt22_YoungParticipants_behav_table4R_with.VN.Tukey.csv"

behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)
names_group=c("young")

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

group_anova <- ezANOVA(pat_age,dv=.(MedianRT),wid = .(SUB),within = .(CUE,DIS),detailed=T)
print(group_anova)

interaction.plot(pat_age$DIS, pat_age$CUE,
                 pat_age$MedianRT, fun= mean,
                 col=c(4,2,5),lwd = 4, lty = 1, ylim=c(450,600),legend = TRUE,xlab="Distractor", ylab="MedianRT")

interaction.plot(pat_age$DIS, pat_age$CUE,
                 pat_age$MedianRTukey, fun= mean,
                 col=c(4,2,5),lwd = 4, lty = 1, ylim=c(450,600),legend = TRUE,xlab="Distractor", ylab="MedianRTukey")

group_anova_perc <- ezANOVA(pat_age,dv=.(PerIncorrect),wid = .(SUB),within = .(CUE,DIS),detailed=T)
print(group_anova_perc)

interaction.plot(pat_age$DIS, pat_age$CUE,
                 pat_age$PerIncorrect, fun= mean,
                 col=c(4,2,5),lwd = 4, lty = 1, ylim=c(0,10),legend = TRUE,xlab="Distractor", ylab="Percentage Incorrect")

group_anova_miss <- ezANOVA(pat_age,dv=.(PerMiss),wid = .(SUB),within = .(CUE,DIS),detailed=T)
print(group_anova_miss)

interaction.plot(pat_age$DIS, pat_age$CUE,
                 pat_age$PerMiss, fun= mean,
                 col=c(4,2,5),lwd = 4, lty = 1, ylim=c(0,10),legend = TRUE,xlab="Distractor", ylab="PerMiss")

group_anova_fa <- ezANOVA(pat_age,dv=.(PerFlaseAlarm),wid = .(SUB),within = .(CUE,DIS),detailed=T)
print(group_anova_fa)

interaction.plot(pat_age$DIS, pat_age$CUE,
                 pat_age$PerFlaseAlarm, fun= mean,
                 col=c(4,2,5),lwd = 4, lty = 1, ylim=c(0,0.2),legend = TRUE,xlab="Distractor", ylab="PerFlaseAlarm")

dis_effect<-pairwise.t.test(pat_age$PerFlaseAlarm,pat_age$DIS,paired=TRUE,p.adjust.method="fdr")
print(dis_effect)

interaction.plot(pat_age$DIS, pat_age$SUB,
                 pat_age$PerFlaseAlarm, fun= mean,
                 col=c(1:25),lwd = 4, lty = 1, ylim=c(0,1),legend = TRUE,xlab="Distractor", ylab="PerFlaseAlarm")
