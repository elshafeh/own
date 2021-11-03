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
library(gridExtra);library(ez)
library(rstatix)

rm(list=ls())
pd              <- position_dodge(0.1)
alphalev        <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

dir_file          <- "/Users/heshamelshafei/gitHub/own/doc/"
fname             <- paste0(dir_file,"eyes_sleepquest.csv")
alldata           <- read.table(fname,sep = ',',header=T)

alldata$sub       <- as.factor(alldata$sub)
alldata$eye       <- as.factor(alldata$eye)
alldata$block     <- as.factor(alldata$block)
alldata$eye_block     <- as.factor(alldata$eye_block)

model_beh           <- lme4::lmer(sleep ~ (eye+eye_block)^2 + (1|sub), data =alldata)
model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
 
res <- emmeans(model_beh, pairwise ~ eye)
print(res)

res <- emmeans(model_beh, pairwise ~ eye_block)
print(res)

erbar_w <- .6; erbar_s <- .8; pd  <- position_dodge(erbar_w+.1)
scat_s  <- 1.5;mean_s  <- 5; font_s  <- 16
plot_lim <- c(0.88,1)
plot_breaks <- seq(1,4,by = 1)
col_map <- "Set1"

sumrepdat           <- summarySE(alldata, measurevar = "sleep", groupvars=c("eye_block"))

ggplot(sumrepdat, aes(x = eye_block, y = sleep_mean))+
  geom_point(shape = 15,position=pd,size=mean_s) +
  geom_errorbar(data = sumrepdat, aes(x = eye_block, y = sleep_mean, 
                                      ymin = sleep_mean-se, ymax = sleep_mean+se), 
                width = erbar_w,size=erbar_s,position=pd)+
  scale_colour_brewer(palette = col_map)+
  scale_fill_brewer(palette = col_map)+
  ggtitle("")+
  scale_y_continuous(name = "Accuracy",breaks =plot_breaks,
                     limits = c(1, 4))+
  theme_pubclean(base_size = font_s,base_family = "Calibri")

sumrepdat           <- summarySE(alldata, measurevar = "sleep", groupvars=c("eye"))

ggplot(sumrepdat, aes(x = eye, y = sleep_mean))+
  geom_point(shape = 15,position=pd,size=mean_s) +
  geom_errorbar(data = sumrepdat, aes(x = eye, y = sleep_mean, 
                                      ymin = sleep_mean-se, ymax = sleep_mean+se), 
                width = erbar_w,size=erbar_s,position=pd)+
  scale_colour_brewer(palette = col_map)+
  scale_fill_brewer(palette = col_map)+
  ggtitle("")+
  scale_y_continuous(name = "Accuracy",breaks =plot_breaks,
                     limits = c(1, 4))+
  theme_pubclean(base_size = font_s,base_family = "Calibri")

sumrepdat           <- summarySE(alldata, measurevar = "sleep", groupvars=c("eye","eye_block"))

ggplot(sumrepdat, aes(x = eye_block, y = sleep_mean, group = eye, colour = eye,fill=eye))+
  geom_point(shape = 15,position=pd,size=mean_s) +
  geom_errorbar(data = sumrepdat, aes(x = eye_block, y = sleep_mean, group = eye, colour = eye,
                                      ymin = sleep_mean-se, ymax = sleep_mean+se),
                width = erbar_w,size=erbar_s,position=pd)+
  scale_colour_brewer(palette = col_map)+
  scale_fill_brewer(palette = col_map)+
  ggtitle("")+
  scale_y_continuous(name = "Sleepiness",breaks =plot_breaks,
                     limits = c(1, 4))+
  theme_pubclean(base_size = font_s,base_family = "Calibri")

# ggplot(alldata, aes(x = block, y = sleep, fill = block)) +
#   geom_flat_violin(aes(block),position = position_nudge(x = .2, y = 0), 
#                    adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
#   geom_boxplot(alpha = .5, width = .35, colour = "black")+
#   scale_fill_grey(start = 0.6, end = 0.1)+
#   scale_x_discrete(name = "")+
#   theme_pubclean(base_size = 14,base_family = "Calibri")+
#   guides(fill=FALSE,color = FALSE, size = FALSE)

# ggplot(alldata, aes(x = eye, y = sleep, fill = eye)) +
#   geom_flat_violin(aes(eye),position = position_nudge(x = .2, y = 0), 
#                    adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
#   geom_boxplot(alpha = .5, width = .35, colour = "black")+
#   scale_fill_grey(start = 0.6, end = 0.1)+
#   scale_x_discrete(name = "")+
#   theme_pubclean(base_size = 14,base_family = "Calibri")+
#   guides(fill=FALSE,color = FALSE, size = FALSE)