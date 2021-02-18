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
pd          <- position_dodge(0.3)
alphalev    <- 0.6

point_size  <-3
line_size   <-1
error_size  <-.2

cbPalette_eyes        <- c("#669933","#FFCC33") 

fname                 <- "P:/3015039.05/data/all_sub/eyes_virt_bin_lat_index_5bin.csv"
sub_table             <- read.table(fname,sep = ',',header=T)

model_acc             <- lme4::lmer(perc_corr ~ (eye+bin)^2 + (1|sub), data =sub_table)
model_acc_anova       <- Anova(model_acc,type=2,test.statistic=c("F"))
print(model_acc_anova)

emmeans(model_acc, pairwise ~ bin | eye)

model_rt        <- lme4::lmer(med_rt ~ (eye+bin)^2 + (1|sub), data =sub_table)
model_rt_anova  <- Anova(model_rt,type=2,test.statistic=c("F"))
print(model_rt_anova)

emmeans(model_acc, pairwise ~ bin | eye)

tgc <- summarySE(sub_table, measurevar="perc_corr", groupvars=c("bin"))

p1 <- ggplot(tgc, aes(x=bin, y=perc_corr)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,group=1,size=line_size) +
  geom_errorbar(aes(ymin=perc_corr-se, ymax=perc_corr+se), width=error_size,size=line_size, position=pd) +
  ylim(0.65,0.8)+theme_clean()+ggtitle(paste0("lat index and accuracy p = ",round(model_acc_anova$`Pr(>F)`[2],2)))

tgc <- summarySE(sub_table, measurevar="med_rt", groupvars=c("bin"))

p2 <- ggplot(tgc, aes(x=bin, y=med_rt)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,group=1,size=line_size) +
  geom_errorbar(aes(ymin=med_rt-se, ymax=med_rt+se), width=error_size, size=line_size,position=pd) +
  ylim(0.6,0.7)+theme_clean()+ggtitle(paste0("lat index and RT p = ",round(model_rt_anova$`Pr(>F)`[2],2)))


tgc <- summarySE(sub_table, measurevar="perc_corr", groupvars=c("bin","eye"))

p3 <- ggplot(tgc, aes(x=bin, y=perc_corr,group=eye,color=eye)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=perc_corr-se, ymax=perc_corr+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_eyes) +scale_fill_manual(values = cbPalette_eyes)+
  ylim(0.65,0.8)+theme_clean()+ggtitle(paste0("lat index and accuracy p = ",round(model_acc_anova$`Pr(>F)`[3],2)))

tgc <- summarySE(sub_table, measurevar="med_rt", groupvars=c("bin","eye"))

p4 <- ggplot(tgc, aes(x=bin, y=med_rt,group=eye,color=eye)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=med_rt-se, ymax=med_rt+se), width=error_size, size=line_size,position=pd) +
  scale_colour_manual(values = cbPalette_eyes) +scale_fill_manual(values = cbPalette_eyes)+
  ylim(0.6,0.7)+theme_clean()+ggtitle(paste0("lat index and RT p = ",round(model_rt_anova$`Pr(>F)`[3],2)))


ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)