library(cowplot)
library(dplyr)
library(readr)
library(ggpubr)
library(lme4)
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

rm(list=ls())

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

alldata           <- read.table("/Users/heshamelshafei/github/own/doc/eyes.behav.fromds.csv",header=T,sep = ',')
alldata$suj       <- as.factor(alldata$suj)
alldata$eye       <- as.factor(alldata$eyes)
alldata$cue       <- as.factor(alldata$cue)
alldata$eye       <- ordered(alldata$eye, levels = c("open", "closed"))

pd                <- position_dodge(0.1)

erbar_w           <- .08
erbar_s           <- .5
scat_s            <- 1.5
mean_s            <- 2.5
font_s            <- 14

title_names       <- c("","")
axes_names        <-c("Percentage of correct responses","Reaction time (s)")

for (nvar in c(1,2)){
  
  if (nvar == 1){
    rep_data      <- alldata
    rep_data$var  <- rep_data$perc
    plot_lim      = c(30,110,10)
  } else if (nvar == 2){
    rep_data      <- alldata
    rep_data$var  <- rep_data$rt
    plot_lim      = c(0.3,1.1,0.1)
  }
  
  rep_data$eye      <- mapvalues(rep_data$eye, from = c("open", "closed"), to = c("1","2"))
  model_beh           <- lme4::lmer(var ~ (eye+cue)å^2 + (1|suj), data =rep_data)
  model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  val_round <- 5
  
  pval1 <- round(model_beh_anova$`Pr(>F)`[1],val_round)
  pval2 <- round(model_beh_anova$`Pr(>F)`[2],val_round)
  pval3 <- round(model_beh_anova$`Pr(>F)`[3],val_round)
  
  map_name  <- c("#FB9A99","#6A3D9A")
  
  pplot <- ggplot(rep_data, aes(x = eye, y = var, fill = cue)) +
    geom_flat_violin(aes(eye),position = position_nudge(x = .2, y = 0), adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
    geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
    scale_colour_manual(values= map_name)+
    scale_fill_manual(values = map_name)+
    ggtitle(paste0("p(eye) = ",pval1,"\n","p(cue) = ",pval2,"\n","p(eye*cue) = ",pval3))+
    scale_y_continuous(name = axes_names[nvar], breaks =seq(plot_lim[1], plot_lim[2], by = plot_lim[3]),limits = c(plot_lim[1], plot_lim[2]))+
    scale_x_discrete(labels = c("open" , "closed"))+
    theme_pubclean(base_size = font_s,base_family = "Calibri")
  
    # geom_point(aes(x = as.numeric(eye)-.15, y = var, group = cue,colour = cue),position = position_jitter(width = .05), 
  #            size = scat_s, shape = 20)+
    # geom_point(data = sumrepdat, aes(x = as.numeric(eye), y = var_median, group = cue, colour = cue,fill=cue), 
    #            shape = 19,position=pd,size=mean_s) +
    # geom_errorbar(data = sumrepdat, aes(x = as.numeric(eye), y = var_median, group = cue, colour = cue, 
    #                                     ymin = var_median-se, ymax = var_median+se), width = erbar_w,size=erbar_s,position=pd)+
    # geom_point(data = sumrepdat, aes(x = as.numeric(eye)+.1, y = var_mean, group = cue, colour = cue,fill=cue), 
    #            shape = 15,position=pd,size=mean_s) +
    # geom_errorbar(data = sumrepdat, aes(x = as.numeric(eye)+.1, y = var_mean, group = cue, colour = cue, 
    #                                     ymin = var_mean-se, ymax = var_mean+se), width = erbar_w,size=erbar_s,position=pd)+
  
  if (nvar == 1){
    p1  = pplot
  } else if (nvar == 2){
    p2 = pplot
  }
  
}

ggarrange(p1,p2,ncol=2,nrow=1)
