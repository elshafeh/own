library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())

name1          <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2          <-  "BroadMan_AgeContrast_Alpha_pmIndex_p600p1100_7t15Hz_addFreqTime_MinEvoked_80Slct.txt"
pat            <- read.table(paste0(name1,name2),header=T)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+TIME+FREQ)^4 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|GROUP),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","GROUP"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=GROUP, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.1,0.1)
