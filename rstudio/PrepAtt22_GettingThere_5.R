library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "/Users/heshamelshafei/GoogleDrive/google_Desktop/14Feb_r_doc/"
ext2        <- "allyc_pmi_index.txt" 
pat         <-  read.table(paste0(ext1,ext2),header=T)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("MOD","HEMI"))

pd <- position_dodge(0.05) 

ggplot(tgc, aes(x=MOD, y=POW, color=HEMI,group=HEMI)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.05,0.05)

model.pat      <- lme4::lmer(POW ~ (MOD+HEMI+FREQ)^3+ (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~HEMI|FREQ),details= TRUE)