library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
ext1  = "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2  = "age_contrast_broadman_MinEvoked_iaf_p600p1000_1Cue_two_occ.txt"
fname = paste0(ext1,ext2, collapse = NULL)
pat   = read.table(fname,header=T)


model1.pat  <- lme4::lmer(IAF ~ (GROUP+MOD+HEMI)^2 + (1|SUB), data =pat)
anova1      <-Anova(model1.pat,type=2,test.statistic=c("F"))

print(anova1)

lsmeans(model1.pat,  pairwise~MOD|GROUP,details= TRUE)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("MOD","GROUP"))

ggplot(pat, aes(x=GROUP, y=IAF, fill=MOD)) +
  geom_boxplot()+
  theme_linedraw()+
  ylim(5,16)

ggplot(pat, aes(x=MOD, y=IAF, fill=HEMI)) +
  geom_boxplot()+
  theme_linedraw()+
  ylim(5,16)+
  facet_wrap(~GROUP)
