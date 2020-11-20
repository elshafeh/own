library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(optimx)
library(simr)

rm(list=ls())

# add in filename jere

ext1           <- "~/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2           <- "ageingpaper_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

## percentages 

model1.pat          <- lme4::lmer(Acc ~ (eyes+cue+freq)^3 + (1|SUB), data =pat)
model_anova1     <- Anova(model1.pat,type=2,test.statistic=c("F"))
print(model_anova1)

lsmeans(model1.pat,  "DIS",details= TRUE, adjust = "mvt")

## reaction times

model2.pat          <- lme4::lmer(RT ~ (eyes+cue+freq)^3 + (1|SUB), data =pat)
model_anova2     <- Anova(model2.pat,type=2,test.statistic=c("F"))

print(model_anova2)
