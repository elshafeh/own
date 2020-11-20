library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
fname =  "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/PrepAtt22_behav_table4R_withTukey.csv"

behav_summary <- read.table(fname,header=T, sep=";")

names_group <- unique(behav_summary$idx_group)
list_grp=c("old","young","patients","control")

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=numeric(), p_miss =numeric(),
                         p_falseAlarm = numeric(),stringsAsFactors=TRUE)

for (gr in 1:length(names_group)){
  
  pat <- behav_summary[behav_summary$idx_group == names_group[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    for (cue in 1:3){
      for (dis in 1:3){
        for (tar in 1:4){
          
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
            
            if (tar%%2 ==0){
              cue_bid = 'NRCue'
            } else {
              cue_bid = 'NLCue'
            }
            
          } else {
            cue_group='Informative'
            cue_bid = cue_names[cue]
          }
          
          
          
          medianRT = median(sub_pat[sub_pat$CORR>0,11])
          medianRT_tukey = median(sub_pat[sub_pat$CORR==1,11])
          
          bloc <- cbind(suj,list_grp[gr],cue_names[cue],dis_names[dis],tar_names[tar],cue_group,p_incorrect,p_miss,p_fa,medianRT,medianRT_tukey,cue_bid)
          
          pat_concat<-rbind(pat_concat,bloc)        
          
          
        }
      }
    }
  }
}
rm(list=setdiff(ls(), "pat_concat"))
names(pat_concat) <- c("SUB","GROUP","CUE","DIS","TAR_SIDE","CUE_CAT","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT","MedianRT_tukey","CUE_GROUPED")

pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]
pat_concat$MedianRT <- as.numeric(levels(pat_concat$MedianRT))[pat_concat$MedianRT]
pat_concat$MedianRT_tukey <- as.numeric(levels(pat_concat$MedianRT_tukey))[pat_concat$MedianRT_tukey]

pat_concat <- pat_concat[complete.cases(pat_concat), ]
pat_concat <- pat_concat[!is.na(pat_concat$MedianRT),]

pat_group <- pat_concat[pat_concat$GROUP=="old" | pat_concat$GROUP=="young",]
pat_group$SUB <- factor(pat_group$SUB)
pat_group$GROUP <- factor(pat_group$GROUP)

# --- model median rt with target side

model.pat   <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+TAR_SIDE+DIS)^2 + (1|SUB), data =pat_group)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_CAT"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,"DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|DIS),details= TRUE)

# --- model median rt without target side

model.pat   <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^2 + (1|SUB), data =pat_group)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_CAT"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,"DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|DIS),details= TRUE)


tgc <- summarySE(pat_group, measurevar="MedianRT", groupvars=c("CUE_GROUPED","DIS","GROUP"))

pd <- position_dodge(0.2)

interaction.ABC.plot(MedianRT, x.factor=DIS,
                     groups.factor=CUE_GROUPED, trace.factor=GROUP,
                     data=pat_group, c,ggplotFunc=list(labs(x="Distractor Delay",y="Median Reaction Time"),
                                                       ggtitle(""),ylim(450,650),
                                                       geom_errorbar(data=tgc,aes(ymax=MedianRT+se, ymin=MedianRT-se),
                                                                     width=0.2,position = pd),
                                                       geom_point(position=pd,size=3, shape=21,fill="white")))


# --- model median rt without target side

model.pat   <- lme4::lmer(PerIncorrect ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat_group)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

tgc <- summarySE(pat_group, measurevar="PerIncorrect", groupvars=c("CUE_CAT","DIS","GROUP"))

pd <- position_dodge(0.2)

interaction.ABC.plot(PerIncorrect, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat_group, c,ggplotFunc=list(labs(x="Distractor Delay",y="% Correct"),
                                                       ggtitle(""),ylim(0,8),
                                                       geom_errorbar(data=tgc,aes(ymax=PerIncorrect+se, ymin=PerIncorrect-se),
                                                                     width=0.2,position = pd),
                                                       geom_point(position=pd,size=3, shape=21,fill="white")))




