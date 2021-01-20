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
fname               <- paste0(dir_file,"eyes_virt_stimlock_behav2fft_withcue.csv")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$eye       <- as.factor(sub_table$eye)
sub_table$cue       <- as.factor(sub_table$cue)
sub_table$cond      <- as.factor(sub_table$cond)
sub_table$measure   <- as.factor(sub_table$measure)
sub_table$compare   <- as.factor(sub_table$compare)

list_measure        <- levels(sub_table$measure)
list_compare        <- levels(sub_table$compare)

font_s              <- 12

for (ncom in 1:length(list_compare)){
  for (nmes in 1:length(list_measure)){
    
    
    rep_data          <- sub_table[sub_table$measure == list_measure[nmes] & sub_table$compare == list_compare[ncom],]
    rep_data$var      <- rep_data$value
    rep_data$eye      <- ordered(rep_data$eye, levels = c("open", "closed"))
    
    if (nmes == 1){
      plot_lim      = c(-1,0.6)
    } else if (nmes == 2){
      plot_lim      = c(-0.6,0.6)
    } else if (nmes == 3){
      plot_lim      = c(-0.3,0.4)
    } else if (nmes == 4){
      plot_lim      = c(0,6)
    }
    
    
    model_beh         <- lme4::lmer(var ~ (eye+cond+cue)^3 + (1|sub), data =rep_data)
    model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
    
    p1<- ggplot(rep_data, aes(x = eye, y = var, fill = cond))+
      geom_boxplot(aes(x = eye, y = var, fill = cond),outlier.shape = NA, 
                   alpha = .5, width = .7, colour = "black")+
      scale_colour_brewer(palette = "Set1")+
      scale_fill_brewer(palette = "Set1")+
      ggtitle(paste0("p-eye           = ",round(model_beh_anova$`Pr(>F)`[1],2),
                     "    p-cond         = ",round(model_beh_anova$`Pr(>F)`[2],2),
                     "\np-eye-cond = ",round(model_beh_anova$`Pr(>F)`[4],2),
                     "    p-cond-cue = ",round(model_beh_anova$`Pr(>F)`[6],2),
                     "\np-3way        = ",round(model_beh_anova$`Pr(>F)`[7],2)))+
      theme_pubclean(base_size = font_s,base_family = "Calibri")+
      scale_y_continuous(name = list_measure[nmes])
    
    print(p1)
    
    # ,breaks =c(plot_lim[1], plot_lim[2],mean(plot_lim)),limits = c(plot_lim[1], plot_lim[2]))+
    #   facet_wrap(~cue)
    
  }
}

