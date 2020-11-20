library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)

rm(list=ls())
names_group=c("old","young","patient","control")

fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R.csv"
behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=numeric(), p_miss =numeric(),
                         p_falseAlarm = numeric(),stringsAsFactors=TRUE)

for (gr in 1:length(list_grp)){
  
  pat <- behav_summary[behav_summary$idx_group == list_grp[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    for (cue in 1:4){
      for (dis in 1:3){
        
        if (cue>2){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-2 & pat$DIS==dis-1,]}
        if (cue==1){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$TAR%%2 != 0 & pat$DIS==dis-1,]}
        if (cue==2){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$TAR%%2 == 0 &pat$DIS==dis-1,]}
        
        suj <- paste0(names_group[gr],sb)
        
        n_incorrect <- lengths(sub_pat[sub_pat$CORR==-1,])[1]
        n_miss <- lengths(sub_pat[sub_pat$ERROR==1,])[1]
        n_fa <- lengths(sub_pat[sub_pat$ERROR==3,])[1]
        n_tot <- lengths(sub_pat)[1]
        
        p_incorrect <- (n_incorrect/n_tot)*100
        p_miss <- (n_miss/n_tot)*100
        p_fa <- (n_fa/n_tot)*100
        
        cue_names = c('NLCue','NRCue','LCue','RCue')
        dis_names = c('D0','D1','D2')
        
        medianRT = median(sub_pat[sub_pat$CORR==1,11])
        
        bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],p_incorrect,p_miss,p_fa,medianRT)
        
        pat_concat<-rbind(pat_concat,bloc)
        
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))

names(pat_concat) <- c("SUB","GROUP","CUE","DIS","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT")


pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]
pat_concat$MedianRT <- as.numeric(levels(pat_concat$MedianRT))[pat_concat$MedianRT]

pat_age <- pat_concat[pat_concat$GROUP=="old" | pat_concat$GROUP=="young",]
pat_age$SUB <- factor(pat_age$SUB)
pat_age$GROUP <- factor(pat_age$GROUP)
pat_old <- pat_concat[pat_concat$GROUP=="old",c(1,3,4,5,6,7,8)]
pat_old$SUB <- factor(pat_old$SUB)
pat_young <- pat_concat[pat_concat$GROUP=="young",c(1,3,4,5,6,7,8)]
pat_young$SUB <- factor(pat_young$SUB)
pat_avc <- pat_concat[pat_concat$GROUP=="patient" | pat_concat$GROUP=="control",]
pat_avc$SUB <- factor(pat_avc$SUB)
pat_avc$GROUP <- factor(pat_avc$GROUP)
pat_patient <- pat_concat[pat_concat$GROUP=="patient",c(1,3,4,5,6,7,8)]
pat_patient$SUB <- factor(pat_patient$SUB)
pat_con <- pat_concat[pat_concat$GROUP=="control",c(1,3,4,5,6,7,8)]
pat_con$SUB <- factor(pat_con$SUB)

#"PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT"

a <- ezANOVA(pat_avc,dv=.(MedianRT),wid = .(SUB),within = .(CUE,DIS),between = (GROUP),detailed=T)
print(a)

a <- ezANOVA(pat_old,dv=.(MedianRT),wid = .(SUB),within = .(DIS),detailed=T)
print(a)

xi <- 5
t.test(pat_avc[pat_avc$DIS=="D0",xi],pat_avc[pat_avc$DIS=="D1",xi])
t.test(pat_avc[pat_avc$DIS=="D0",xi],pat_avc[pat_avc$DIS=="D2",xi])
t.test(pat_avc[pat_avc$DIS=="D1",xi],pat_avc[pat_avc$DIS=="D2",xi])


#
#
## for each group
#
#

model.pat <- lme4::lmer(MedianRT ~ (CUE+DIS)^2 + (1|SUB), data =pat_con)
a         <-Anova(model.pat,type=2,test.statistic = c("F"))
print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat, "DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE|DIS))
