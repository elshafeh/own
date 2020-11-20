library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
name1 <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2 <-  "BroadAreas_AgeContrast_Alpha_AuditoryOccipital_AllTrials_MinEvoked_RLN_p600p1100_addTimeFreq_80Slct.txt"

pat   <- read.table(paste0(name1,name2),header=T)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+FREQ+TIME+MOD+HEMI)^5 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)