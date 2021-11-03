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

dir_file              <- "~/github/own/doc/"
fname                 <- paste0(dir_file,"eyes.virt.1vox.binning.rel.vis.csv")
alldata               <- read.table(fname,sep = ',',header=T)

alldata$sub           <- as.factor(alldata$sub)
alldata$eye           <- as.factor(alldata$eye)
alldata$bin           <- as.factor(alldata$bin)
alldata$eye          <- ordered(alldata$eye, levels = c("open", "closed"))

list_measure          <- c("accuracy","rt")

for (ncom in 1:length(list_measure)){
  
  if (ncom == 1){
    
    rep_data          <- alldata
    rep_data$var      <- rep_data$perc
    plot_lim          <- c(0.5,1)
    
  } else if (ncom == 2){
    
    rep_data          <- alldata
    rep_data$var      <- rep_data$rt
    plot_lim          <- c(0.4,1)
    
  }
  
  model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
  model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,bin)
  )
  print(e_anova$ANOVA)
  

  # res <-  emmeans(model_beh, pairwise ~ bin)
  # print(res)
  
  list_eyes           <- c("open","closed")
  
  for (neyes in 1:length(list_eyes)){
    
    sub_data <- rep_data[rep_data$eye == list_eyes[neyes],]
    sub_data$eyes      <- as.factor(sub_data$eye)
    
    pplot <- ggplot(sub_data, aes(x = bin, y = var, fill = bin)) +
      # geom_line(aes(group=sub),color='gray',size=0.2,alpha=0.6)+
      geom_boxplot(alpha = .5, width = .35, colour = "black")+ #outlier.shape = NA, 
      ggtitle(list_measure[ncom])+
      scale_x_discrete(name = list_eyes[neyes])+
      scale_y_continuous(name = "",limit = plot_lim)+
      theme_pubr(base_size = 12,base_family = "Calibri")+
      guides(fill=FALSE,color = FALSE, size = FALSE)
    
    if (ncom == 1 & neyes == 1){
      p1  = pplot
    } else if (ncom == 1 & neyes == 2){
      p2 = pplot
    } else if (ncom == 2 & neyes == 1){
      p3 = pplot 
    } else if (ncom == 2 & neyes == 2){
      p4 = pplot 
    }
    
  }
  
}

fullfig <- ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)
fullfig


