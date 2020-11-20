# Initiate Libraries ####

library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)


##### Double Check Differences #####

rm(list=ls())
pd          <- position_dodge(0.1)

fname1      <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/r_data/"
fname2      <- "Scndround_pat22DIS.mpdc.broad.60t90Hz10step.txt"
con_table   <- read.table(paste0(fname1,fname2),sep = ',',header=T)

model.pat      <- lme4::lmer(grng   ~ (cond+chn)^2 + (1|sub), data =con_table) # PerCorrect
lsmeans(model.pat, pairwise~cond|chn,details= TRUE,adjust="bonferroni")

# lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~cond|chn,details= TRUE,adjust="bonferroni"))
# model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
# print(model_anova)
# model.pat      <- lme4::lmer(grng   ~ (freq+cond+chn)^3 + (1|sub), data =con_table) # PerCorrect
# model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
# print(model_anova)
# 
tgc <- summarySE(con_table, measurevar="grng", groupvars=c("cond","chn"))

ggplot(tgc, aes(x=chn, y=grng, fill=cond)) +
  # geom_boxplot()+
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=grng-se, ymax=grng+se), width=.2, position=position_dodge(.9))+
  scale_fill_brewer(palette="Accent") + 
  theme_minimal()
