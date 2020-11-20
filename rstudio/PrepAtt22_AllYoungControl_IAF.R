library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
ext1=  "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
#ext2  = "AudioVisualbroadman_AllYoung_IAF_AllTrials_withCueConditions_100Slct.txt"
ext2  = "AudioVisualbroadman_AllYoung_IAF_AllTrials_withCueConditions_AllTrials.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(IAF ~ (CUE+HEMI+MOD)^3 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("HEMI","MOD"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=HEMI, y=IAF, color=MOD,group=MOD)) + 
  geom_errorbar(aes(ymin=IAF-se, ymax=IAF+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(8,14)


