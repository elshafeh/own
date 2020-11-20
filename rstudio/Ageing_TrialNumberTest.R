library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
ext1=  "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
ext2  = "PrepAtt22_TrialCount_3Cue.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(Ntrials ~ (GROUP+CUE_SIDE)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="Ntrials", groupvars=c("GROUP","CUE_SIDE"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CUE_SIDE, y=Ntrials,color=GROUP,group=GROUP)) + 
  geom_errorbar(aes(ymin=Ntrials-se, ymax=Ntrials+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(95,250)

tgc <- summarySE(pat, measurevar="NTrials", groupvars=c("GROUP","CUE_CAT","TAR_SIDE"))

interaction.ABC.plot(NTrials, x.factor=TAR_SIDE,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="TARGET SIDE",y="Number of Trials"),
                                                       ggtitle(""),ylim(100,115),
                                                       geom_errorbar(data=tgc,aes(ymax=NTrials+se, ymin=NTrials-se),
                                                                     width=0.2,position = pd),
                                                       geom_point(position=pd,size=3, shape=21,fill="white")))



