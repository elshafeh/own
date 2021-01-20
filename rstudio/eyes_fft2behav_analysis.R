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
fname               <- paste0(dir_file,"eyes_virt_allock_binning_combined_meanpeak.csv")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$eye       <- as.factor(sub_table$eye)
sub_table$bin       <- as.factor(sub_table$bin)
sub_table$bin_fac   <- as.factor(sub_table$bin_fac)
sub_table$window    <- as.factor(sub_table$window)

list_window         <- levels(sub_table$window)
list_fac            <- levels(sub_table$bin_fac)
list_var            <- c("% correct","median RT")
i                   <- 0

pd                  <- position_dodge(0.1)
erbar_w             <- .1
erbar_s             <- .5
scat_s              <- 1.5
mean_s              <- 2.5
font_s              <- 12

# plot
for (nwin in c(1,2,3,4,5)){
  
  myplots           <- list()
  i                 <- 0
  
  for (nvar in (c(1,2))){
    for (nfac in c(1,2,3,4)){
      
      rep_data      <- sub_table[sub_table$window == list_window[nwin] & sub_table$bin_fac == list_fac[nfac],]
      rep_data$bin  <- mapvalues(rep_data$bin, from = c("b1", "b2","b3","b4","b5"), to = c("1","2","3","4","5"))
      
      if (nvar == 1){
        rep_data$var  = rep_data$perc_corr
        plot_lim      = c(0.68,0.85)
      } else if (nvar == 2){
        rep_data$var  = rep_data$med_rt
        plot_lim      = c(0.58,0.72)
      }
      
      model_beh        <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
      model_beh_anova  <- Anova(model_beh,type=2,test.statistic=c("F"))
      
      sumrepdat       <- summarySE(rep_data, measurevar = "var", groupvars=c("eye","bin"))
      
      
      p1              <- ggplot(rep_data, aes(x = bin, y = var, fill = eye))+
        geom_point(data = sumrepdat, aes(x = as.numeric(bin), y = var_mean, group = eye, colour = eye,fill=eye), 
                   shape = 15,position=pd,size=mean_s) +
        geom_errorbar(data = sumrepdat, aes(x = as.numeric(bin), y = var_mean, group = eye, colour = eye, 
                                            ymin = var_mean-se, ymax = var_mean+se), width = erbar_w,size=erbar_s,position=pd)+
        geom_line(data = sumrepdat, aes(x = as.numeric(bin), y = var_mean, group = eye, colour = eye), 
                  position=pd)+
        scale_colour_brewer(palette = "Dark2")+
        scale_fill_brewer(palette = "Dark2")+
        ggtitle(paste0("pe=",round(model_beh_anova$`Pr(>F)`[1],2),
                       " pb=",round(model_beh_anova$`Pr(>F)`[2],2),
                       " pi=",round(model_beh_anova$`Pr(>F)`[3],2)))+
        theme_pubclean(base_size = font_s,base_family = "Calibri")+
        scale_y_continuous(name = list_var[nvar],
                           breaks =c(plot_lim[1], plot_lim[2],mean(plot_lim)),limits = c(plot_lim[1], plot_lim[2]))+
        scale_x_continuous(name = list_fac[nfac])
      
      i                 <- i+1
      myplots[[i]]      <- p1
      
    }
  }
  
  grid.arrange(grobs = myplots, ncol = 4,nrow,2,
               top = list_window[nwin])

}


# posthoc: visual and accuracy
rep_data          <- sub_table[sub_table$window == "stim500pre" & sub_table$bin_fac == "vis",]
rep_data$var      <- rep_data$perc_corr
model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin)

# posthoc: lat and rt
rep_data          <- sub_table[sub_table$window == "stim500pre" & sub_table$bin_fac == "lat",]
rep_data$var      <- rep_data$med_rt
model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin)

# posthoc: lat and accuracy
rep_data          <- sub_table[sub_table$window == "stim500pre" & sub_table$bin_fac == "lat",]
rep_data$var      <- rep_data$perc_corr
model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin|eye)


# posthoc: contra/vis and accuracy
rep_data          <- sub_table[sub_table$window == "stim500pre" & sub_table$bin_fac == "bal_ip_v",]
rep_data$var      <- rep_data$perc_corr
model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin)

# posthoc: contra/vis and rt
rep_data          <- sub_table[sub_table$window == "stim500pre" & sub_table$bin_fac == "bal_ip_v",]
rep_data$var      <- rep_data$med_rt
model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin)

# posthoc: contra/inh and rt
rep_data          <- sub_table[sub_table$window == "stim500pre" & sub_table$bin_fac == "bal_ip_i",]
rep_data$var      <- rep_data$med_rt
model_beh         <- lme4::lmer(var ~ (eye+bin)^2 + (1|sub), data =rep_data)
model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
print(model_beh_anova)
emmeans(model_beh, pairwise ~ bin)