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

erbar_w <- .2; erbar_s <- .8; pd  <- position_dodge(erbar_w+.1)
scat_s  <- 1.5;mean_s  <- 5; font_s  <- 16

dir_file              <- "/Users/heshamelshafei/gitHub/own/doc/"

# fname                 <- paste0(dir_file,"nback_binning_behavior_preconcat2bins.restrict.txt")
# fname               <- paste0(dir_file,"nback_binning_behavior_exl500concat2bins.prepost.txt")
fname               <- paste0(dir_file,"nback_binning_behavior_preconcat2bins.0back.txt")
sub_table             <- read.table(fname,sep = ',',header=T)

sub_table <- sub_table[sub_table$win == "pre",]
sub_table <- sub_table[sub_table$band == "alpha" | sub_table$band == "beta",]

sub_table$sub         <- as.factor(sub_table$sub);sub_table$band        <- as.factor(sub_table$band)
sub_table$bin         <- as.factor(sub_table$bin);sub_table$win         <- as.factor(sub_table$win)
sub_table$rt          <- sub_table$rt /1000
sub_table$rt_correct  <- sub_table$rt_correct /1000

model_beh           <- lme4::lmer(acc ~ (band+bin)^2 + (1|sub), data =sub_table)
model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin|band)

model_beh           <- lme4::lmer(rt_correct ~ (band+bin)^2 + (1|sub), data =sub_table)
model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin)

col_map <- c("#3339FF","#F0290D") # "#37E941"

p1 <- ggplot(sub_table, aes(x = band, y = acc, fill = bin)) +
  geom_flat_violin(aes(band),position = position_nudge(x = .2, y = 0),
                   adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
  geom_boxplot(alpha = .5, width = .35, colour = "black")+
  scale_colour_manual(values= col_map)+
  scale_fill_manual(values = col_map)+
  scale_y_continuous(name = '',limits = c(0.5,1.1),breaks = c(0.5,0.7,0.9,1.1))+
  ggtitle('Accuracy')+
  scale_x_discrete(name = '')+
  theme_pubclean(base_size = 16,base_family = "Calibri")


p2 <- ggplot(sub_table, aes(x = band, y = rt_correct, fill = bin)) +
  geom_flat_violin(aes(band),position = position_nudge(x = .2, y = 0),
                   adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
  geom_boxplot(alpha = .5, width = .35, colour = "black")+
  scale_colour_manual(values= col_map)+
  scale_fill_manual(values = col_map)+
  scale_y_continuous(name = '',limits = c(0,1.2),breaks=(c(0,0.4,0.8,1.2)))+
  scale_x_discrete(name = '')+
  ggtitle('Reaction time')+
  theme_pubclean(base_size = 16,base_family = "Calibri")

fullfig <- ggarrange(p1,p2,ncol=2,nrow=1)
fullfig

