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
library(multcomp);library(emmeans);
library(gridExtra)

rm(list=ls())

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")

dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/"
fname               <- paste0(dir_file,"nback_binning_behavior_exl500concat3bins_withback.txt")
# fname               <- paste0(dir_file,"nback_binning_behavior_exl500concat3bins.txt")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$band      <- as.factor(sub_table$band)
sub_table$bin       <- as.factor(sub_table$bin)
sub_table$cond      <- as.factor(sub_table$cond)

rep_data            <- sub_table
rep_data$band       <- ordered(rep_data$band, levels = c("slow","alpha","beta","gamma1","gamma2"))

model_beh           <- lme4::lmer(acc ~ (band+bin+cond)^3 + (1|sub), data =rep_data)
# model_beh           <- lme4::lmer(acc ~ (band+bin)^2 + (1|sub), data =rep_data)
model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)

emmeans(model_beh, pairwise ~ bin|band)

## ----------------------------------------------

sumrepdat           <- summarySE(rep_data, measurevar = "acc", 
                                 groupvars=c("band","bin"))

col_map <- "Set1"

erbar_w <- .6; erbar_s <- .8; pd  <- position_dodge(erbar_w+.1)
scat_s  <- 1.5;mean_s  <- 5; font_s  <- 16
plot_lim <- c(0.88,1)
plot_breaks <- seq(plot_lim[1],plot_lim[2],by = 0.02)

ggplot(sumrepdat, aes(x = band, y = acc_mean, group = bin, colour = bin,fill=bin))+
  geom_point(shape = 15,position=pd,size=mean_s) +
  geom_errorbar(data = sumrepdat, aes(x = band, y = acc_mean, group = bin, colour = bin, 
                                      ymin = acc_mean-se, ymax = acc_mean+se), 
                width = erbar_w,size=erbar_s,position=pd)+
  scale_colour_brewer(palette = col_map)+
  scale_fill_brewer(palette = col_map)+
  ggtitle("")+
  scale_y_continuous(name = "Accuracy",breaks =plot_breaks,
                     limits = c(plot_lim[1], plot_lim[2]))+
  theme_pubclean(base_size = font_s,base_family = "Calibri")

## ----------------------------------------------

model_beh           <- lme4::lmer(rt ~ (band+bin+cond)^2 + (1|sub), data =rep_data)
model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)

col_map <- "Dark2"

sumrepdat           <- summarySE(rep_data, measurevar = "rt", groupvars=c("bin","cond"))
erbar_w <- .2; plot_lim  <- c(0.5,0.65)
plot_breaks         <- seq(plot_lim[1],plot_lim[2],by = 0.05)

ggplot(rep_data, aes(x = bin, y = rt,group = cond, colour = cond)) +
  geom_point(data = sumrepdat, aes(x = bin, y = rt_mean,group = cond, colour = cond), 
             shape = 15,position=pd,size=mean_s) +
  geom_errorbar(data = sumrepdat, aes(x = bin, y = rt_mean, group = cond, colour = cond,
                                      ymin = rt_mean-se, ymax = rt_mean+se), 
                width = erbar_w,size=erbar_s,position=pd)+
  scale_colour_brewer(palette = col_map)+
  scale_fill_brewer(palette = col_map)+
  ggtitle("")+
  theme_pubclean(base_size = font_s,base_family = "Calibri")+
  scale_y_continuous(name = "Reaction time",breaks =plot_breaks,
                     limits = c(plot_lim[1], plot_lim[2]))

# sumrepdat           <- summarySE(rep_data, measurevar = "rt", groupvars=c("cond"))
# erbar_w <- .2; plot_lim  <- c(550,650)
# plot_breaks         <- seq(plot_lim[1],plot_lim[2],by = 50)
# 
# ggplot(rep_data, aes(x = cond, y = rt)) +
#   geom_point(data = sumrepdat, aes(x = cond, y = rt_mean), 
#              shape = 15,position=pd,size=mean_s) +
#   geom_errorbar(data = sumrepdat, aes(x = cond, y = rt_mean, 
#                                       ymin = rt_mean-se, ymax = rt_mean+se), 
#                 width = erbar_w,size=erbar_s,position=pd)+
#   scale_colour_brewer(palette = "Dark2")+
#   scale_fill_brewer(palette = "Dark2")+
#   ggtitle("")+
#   theme_pubclean(base_size = font_s,base_family = "Calibri")+
#   scale_y_continuous(breaks =plot_breaks,
#                      limits = c(plot_lim[1], plot_lim[2]))

