library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())

name1          <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2          <-  "3Groups_BroadAuditoryOccipital_WoppiInformation_Index_Baseline_Corrected_MinusEvokedEachCondition_80Slct.txt"
pat            <- read.table(paste0(name1,name2),header=T)
pat            <- pat[pat$CHAN == "aud_L" | pat$CHAN == "aud_R",] ; pat$CHAN <- factor(pat$CHAN)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE+CHAN+TIME+FREQ)^5 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

pat_yc            <- pat[pat$GROUP == "young",]
pat_oc            <- pat[pat$GROUP == "old",]

model.pat_yc      <- lme4::lmer(POW ~ (CUE+FREQ+CHAN)^3 + (1|SUB), data =pat_yc)
model.pat_oc      <- lme4::lmer(POW ~ (CUE+FREQ+CHAN)^3 + (1|SUB), data =pat_oc)

model_anova_yc    <- Anova(model.pat_yc,type=2,test.statistic=c("F"))
model_anova_oc    <- Anova(model.pat_oc,type=2,test.statistic=c("F"))

print(model_anova_yc)
print(model_anova_oc)
