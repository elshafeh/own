library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "//Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "prep21_TrialCount.txt"
pat         <-  read.table(paste0(ext1,ext2),header=T)

model.pat_plv   <- lme4::lmer(Ntrials ~ (CUE_CAT) + (1|SUB), data =pat)
model_anova_plv <-Anova(model.pat_plv,type=2,test.statistic=c("F"))
print(model_anova_plv)
