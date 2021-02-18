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
pd          <- position_dodge(0.1)
alphalev    <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/"
list_measure        <- c("acc","rt")

myplots             <- list()
i                   <- 0

for (nm in 1:length(list_measure)){
  
  fname             <- paste0(dir_file,"corr_vis_",list_measure[nm],'.csv')
  sub_table         <- read.table(fname,sep = ',',header=T)
  sub_table$sub     <- as.factor(sub_table$sub)
  sub_table$eye     <- as.factor(sub_table$eyes)
  sub_table$cond    <- as.factor(sub_table$cond)
  
  rep_data          <- sub_table
  rep_data$var      <- rep_data$pow
  rep_data$eye      <- ordered(rep_data$eye, levels = c("open", "closed"))
  
  model_beh         <- lme4::lmer(pow ~ (eye+cond)^2 + (1|sub), data =rep_data)
  model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
  
  sumrepdat         <- summarySE(rep_data, measurevar = "var", groupvars=c("eye","cond"))
  
  p1                <- ggplot(rep_data, aes(x = cond, y = var, fill = eye))+
    geom_boxplot(aes(x = cond, y = var, fill = eye),outlier.shape = NA, 
                 alpha = .5, width = .5, colour = "black")+
    scale_colour_brewer(palette = "Dark2")+
    scale_fill_brewer(palette = "Dark2")+
    ggtitle(paste0("p(eye) = ",round(model_beh_anova$`Pr(>F)`[1],2),"\n",
                   "p(behavior) = ",round(model_beh_anova$`Pr(>F)`[2],2),"\n",
                   "p(interaction) = ",round(model_beh_anova$`Pr(>F)`[3],2)))+
    scale_y_continuous(name = "normalised visual\nalpha power")+
    scale_x_discrete(name = "")+
    theme_pubclean(base_size = 12,base_family = "Calibri")
  
  i                 <- i+1
  myplots[[i]]      <- p1
  
}

grid.arrange(grobs = myplots, ncol = 1,nrow,2)