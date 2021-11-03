library(dae);library(nlme);library(effects);
library(psych);library(interplot);library(plyr);
library(devtools);library(ez);library(Rmisc);
library(wesanderson)
library(lme4);library(lsmeans);library(plotly);
library(ggplot2);library(ggpubr);library(dplyr)
library(ggthemes);library(extrafont)
library(car);library(ggplot2)
library(optimx);library(simr)
library(tidyverse)
library(hrbrthemes)
library(viridis);library(afex)
library(multcomp);library(emmeans)

rm(list=ls())
pd                  <- position_dodge(0.2)
alphalev            <- 0.6

cbPalette_eyes      <- c("#669933","#FFCC33") 
cbPalette_cue       <- c("#0066CC","#CC0066") 

point_size          <- 3
line_size           <- 1
error_size          <- .2


fname               <- "/Users/heshamelshafei/github/own/doc/eyes_virt_behav.csv"
sub_table           <- read.table(fname,sep = ',',header=T)
sub_table$eye       <- factor(sub_table$eye , levels = c("open","close")) # re-order factor names


model_acc           <- lme4::lmer(perc_corr ~ (eye+cue)^2 + (1|suj), data =sub_table)
model_acc_anova     <- Anova(model_acc,type=2,test.statistic=c("F"))
print(model_acc_anova)

tgc <- summarySE(sub_table, measurevar="perc_corr", groupvars=c("eye","cue"))

p1 <- ggplot(tgc, aes(x=eye, y=perc_corr,group=cue,color =cue)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=perc_corr-se, ymax=perc_corr+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_cue) +scale_fill_manual(values = cbPalette_cue)+
  ylim(0.7,0.8)+theme_clean()+ggtitle("correct responses")

model_inacc           <- lme4::lmer(perc_icor ~ (eye+cue)^2 + (1|suj), data =sub_table)
model_inacc_anova     <- Anova(model_inacc,type=2,test.statistic=c("F"))
print(model_acc_anova)

tgc <- summarySE(sub_table, measurevar="perc_icor", groupvars=c("eye","cue"))

p2 <- ggplot(tgc, aes(x=eye, y=perc_icor,group=cue,color =cue)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=perc_icor-se, ymax=perc_icor+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_cue) +scale_fill_manual(values = cbPalette_cue)+
  ylim(0.2,0.3)+theme_clean()+ggtitle("incorrect responses")

model_miss           <- lme4::lmer(perc_miss ~ (eye+cue)^2 + (1|suj), data =sub_table)
model_miss_anova     <- Anova(model_miss,type=2,test.statistic=c("F"))
print(model_miss_anova)

tgc <- summarySE(sub_table, measurevar="perc_miss", groupvars=c("eye","cue"))

p3 <- ggplot(tgc, aes(x=eye, y=perc_miss,group=cue,color =cue)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=perc_miss-se, ymax=perc_miss+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_cue) +scale_fill_manual(values = cbPalette_cue)+
  ylim(0.0,0.04)+theme_clean()+ggtitle("missed responses")


model_rt           <- lme4::lmer(med_rt ~ (eye+cue)^2 + (1|suj), data =sub_table)
model_rt_anova     <- Anova(model_rt,type=2,test.statistic=c("F"))
print(model_rt_anova)

tgc <- summarySE(sub_table, measurevar="med_rt", groupvars=c("eye","cue"))

p4 <- ggplot(tgc, aes(x=eye, y=med_rt,group=cue,color =cue)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=med_rt-se, ymax=med_rt+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_cue) +scale_fill_manual(values = cbPalette_cue)+
  ylim(0.55,0.75)+theme_clean()+ggtitle("Median RT")

ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)