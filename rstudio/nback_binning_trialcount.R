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
fname               <- paste0(dir_file,"nback_binning_behavior_exl500concat_trialcount.txt")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$band      <- as.factor(sub_table$band)
sub_table$bin       <- as.factor(sub_table$bin)
sub_table$cond      <- as.factor(sub_table$cond)
sub_table$stim      <- as.factor(sub_table$stim)

model_beh           <- lme4::lmer(count ~ (cond+stim+band+bin)^4 + (1|sub), data =sub_table)
model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)

sumrepdat           <- summarySE(sub_table, measurevar = "count", 
                                 groupvars=c("band","bin","cond"))

erbar_w <- .6; erbar_s <- .8; pd  <- position_dodge(erbar_w+.1)
scat_s  <- 1.5;mean_s  <- 5; font_s  <- 16
plot_lim <- c(6,20)
plot_breaks <- seq(plot_lim[1],plot_lim[2],by = 2)

ggplot(sub_table, aes(x = band, y = count, fill = bin)) +
  geom_point(data = sumrepdat, aes(x = band, y = count_mean, group = bin, 
                                   colour = bin,fill=bin), 
             shape = 15,position=pd,size=mean_s) +
  geom_errorbar(data = sumrepdat, aes(x = band, y = count_mean, group = bin, colour = bin, 
                                      ymin = count_mean-se, ymax = count_mean+se), 
                width = erbar_w,size=erbar_s,position=pd)+
  scale_colour_brewer(palette = "Dark2")+
  scale_fill_brewer(palette = "Dark2")+
  ggtitle("")+
  theme_pubclean(base_size = font_s,base_family = "Calibri")+
  scale_y_continuous(breaks =plot_breaks,
                     limits = c(plot_lim[1], plot_lim[2]))+facet_wrap(~cond)
