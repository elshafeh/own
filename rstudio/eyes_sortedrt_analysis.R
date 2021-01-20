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

fname               <- "P:/3015039.05/data/all_sub/eyes_virt_rtsorted.csv"
sub_table           <- read.table(fname,sep = ',',header=T)

model_acc           <- lme4::lmer(perc ~ (eye+bin+cue)^2 + (1|suj), data =sub_table)
model_acc_anova     <- Anova(model_acc,type=2,test.statistic=c("F"))
print(model_acc_anova)

emmeans(model_acc, pairwise ~ bin)

tgc <- summarySE(sub_table, measurevar="perc", groupvars=c("bin","cue"))

p1 <- ggplot(tgc, aes(x=bin, y=perc,group=cue,color =cue)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=perc-se, ymax=perc+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_cue) +scale_fill_manual(values = cbPalette_cue)+
  ylim(0.6,0.9)+theme_clean()+ggtitle("RT bins and accuracy")

model_vis           <- lme4::lmer(vis ~ (eye+bin+cue)^3 + (1|suj), data =sub_table)
model_vis_anova     <- Anova(model_vis,type=2,test.statistic=c("F"))
print(model_vis_anova)

tgc <- summarySE(sub_table, measurevar="vis", groupvars=c("bin","eye"))

p2 <- ggplot(tgc, aes(x=bin, y=vis,group=eye,color =eye)) + 
  geom_point(position=pd, size=point_size)+
  geom_line(position=pd,size=line_size) +
  geom_errorbar(aes(ymin=vis-se, ymax=vis+se), width=error_size,size=line_size, position=pd) +
  scale_colour_manual(values = cbPalette_eyes) +scale_fill_manual(values = cbPalette_eyes)+
  ylim(0,3)+theme_clean()+ggtitle("RT bins and visual alpha")

model_lat           <- lme4::lmer(lat ~ (eye+bin+cue)^3 + (1|suj), data =sub_table)
model_lat_anova     <- Anova(model_lat,type=2,test.statistic=c("F"))
print(model_lat_anova)


# model_trl           <- lme4::lmer(trl ~ (eye+bin+cue)^3 + (1|suj), data =sub_table)
# model_trl_anova     <- Anova(model_trl,type=2,test.statistic=c("F"))
# print(model_trl_anova)
# 
# tgc <- summarySE(sub_table, measurevar="trl", groupvars=c("eye","cue"))
# 
# ggplot(tgc, aes(x=cue, y=trl,group=eye,color =eye)) + 
#   geom_point(position=pd, size=point_size)+
#   geom_line(position=pd,size=line_size) +
#   geom_errorbar(aes(ymin=trl-se, ymax=trl+se), width=error_size,size=line_size, position=pd) +
#   scale_colour_manual(values = cbPalette_eyes) +scale_fill_manual(values = cbPalette_eyes)+
#   theme_clean()+ggtitle("RT bins and trial number")

