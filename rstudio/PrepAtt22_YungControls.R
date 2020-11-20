library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
fname = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/behav4R/PrepAtt22_behav_table4R_withTukey.csv"
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
    
    for (cue in 1:3){
      for (dis in 1:3){
        #for (tar in 1:4){
        
        sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-1 &pat$DIS==dis-1,]
        
        suj <- paste0(names_group[gr],sb)
        
        n_incorrect <- lengths(sub_pat[sub_pat$CORR==-1,])[1]
        n_miss <- lengths(sub_pat[sub_pat$ERROR==1,])[1]
        n_fa <- lengths(sub_pat[sub_pat$ERROR==3,])[1]
        n_tot <- lengths(sub_pat)[1]
        
        p_incorrect <- (n_incorrect/n_tot)*100
        p_miss <- (n_miss/n_tot)*100
        p_fa <- (n_fa/n_tot)*100
        
        #cue_names = c('Inf','Unf')
        
        cue_names = c('NCue','LCue','RCue')
        dis_names = c('D0','D1','D2')
        tar_names = c('Left','Right','Left','Right')
        
        if (cue==1) {
          cue_group='UnInformative'
        } else {
          cue_group='Informative'
        }
        
        medianRT = median(sub_pat[sub_pat$CORR>0,11])
        medianRT_tukey = median(sub_pat[sub_pat$CORR==1,11])
        
        #bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],tar_names[tar],cue_group,p_incorrect,p_miss,p_fa,medianRT,medianRT_tukey)
        bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],cue_group,p_incorrect,p_miss,p_fa,medianRT,medianRT_tukey)
        
        pat_concat<-rbind(pat_concat,bloc)
        
        #}
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))
#names(pat_concat) <- c("SUB","GROUP","CUE","DIS","CUE_CAT","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT","MedianRT_tukey")
names(pat_concat) <- c("SUB","GROUP","CUE","DIS","CUE_CAT","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT","MedianRT_tukey")

pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]
pat_concat$MedianRT <- as.numeric(levels(pat_concat$MedianRT))[pat_concat$MedianRT]
pat_concat$MedianRT_tukey <- as.numeric(levels(pat_concat$MedianRT_tukey))[pat_concat$MedianRT_tukey]

pat_concat <- pat_concat[complete.cases(pat_concat), ]
pat_concat <- pat_concat[!is.na(pat_concat$MedianRT),]

group_anova <- ezANOVA(pat_concat,dv=.(MedianRT),wid = .(SUB),within = .(CUE_CAT,DIS),detailed=T)
print(group_anova)

tgc <- summarySE(pat_concat, measurevar="MedianRT", groupvars=c("CUE_CAT","DIS"))

interaction.ABC.plot(MedianRT, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat_concat, c,ggplotFunc=list(labs(x="Distractor Delay",y="Median Reaction Time"),ggtitle(""),ylim(450,700),geom_errorbar(data=tgc,
                                                                                                                                                   aes(ymax=MedianRT+se, ymin=MedianRT-se),width=0.2)))

dis_effect<-pairwise.t.test(pat_concat$MedianRT,pat_concat$DIS,paired=TRUE,p.adjust.method="fdr")
print(dis_effect)

group_anova <- ezANOVA(pat_concat,dv=.(PerIncorrect),wid = .(SUB),within = .(CUE_CAT,DIS),detailed=T)
print(group_anova)

tgc <- summarySE(pat_concat, measurevar="PerIncorrect", groupvars=c("CUE_CAT","DIS"))

interaction.ABC.plot(PerIncorrect, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat_concat, c,ggplotFunc=list(labs(x="Distractor Delay",y="PerIncorrect"),ggtitle(""),ylim(0,7.5),geom_errorbar(data=tgc,
                                                                                                                                                   aes(ymax=PerIncorrect+se, ymin=PerIncorrect-se),width=0.2)))
dis_effect<-pairwise.t.test(pat_concat$PerIncorrect,pat_concat$DIS,paired=TRUE,p.adjust.method="fdr")
print(dis_effect)

group_anova <- ezANOVA(pat_concat,dv=.(PerFlaseAlarm),wid = .(SUB),within = .(CUE_CAT,DIS),detailed=T)
print(group_anova)

tgc <- summarySE(pat_concat, measurevar="PerFlaseAlarm", groupvars=c("CUE_CAT","DIS"))

interaction.ABC.plot(PerFlaseAlarm, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat_concat, c,ggplotFunc=list(labs(x="Distractor Delay",y="PerFlaseAlarm"),ggtitle(""),ylim(0,0.25),geom_errorbar(data=tgc,
                                                                                                                                          aes(ymax=PerFlaseAlarm+se, ymin=PerFlaseAlarm-se),width=0.2)))
dis_effect<-pairwise.t.test(pat_concat$PerFlaseAlarm,pat_concat$DIS,paired=TRUE,p.adjust.method="fdr")
print(dis_effect)
