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
pd          <- position_dodge(0.1)
alphalev    <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

list_peak               <- c("alpha","beta")
list_name               <- c("sensor") # sensor corinne source 
list_roi                <- c("vptm") # broad , vptm 


for (nroi in 1:length(list_roi)){
  for (nlevel in 1:length(list_name)){
    
    myplots             <- list()
    i                   <- 0
    
    
    for (npeak in 1:length(list_peak)){
      
      dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/"
      fname               <- paste0(dir_file,
                                    "eyes_visualvirt_stimlock_behav2fft.",list_roi[nroi],".",
                                    list_name[nlevel],".", list_peak[npeak],
                                    ".peaks.csv")
      sub_table           <- read.table(fname,sep = ',',header=T)
      
      sub_table$sub       <- as.factor(sub_table$sub);sub_table$eye <- as.factor(sub_table$eye)
      sub_table$behavior  <- as.factor(sub_table$cond);sub_table$roi <- as.factor(sub_table$roi)
      sub_table$compare   <- as.factor(sub_table$compare);sub_table$window <- as.factor(sub_table$window)
      
      list_compare        <- c("accuracy_e","rt")
      list_maps           <- c("Set1","Set1","Set1")
      
      font_s              <- 12
      
      # plot
      for (ncom in 1:length(list_compare)){
        
        rep_data            <- sub_table[sub_table$compare == list_compare[ncom],]
        rep_data$var        <- rep_data$value
        rep_data$eye        <- ordered(rep_data$eye, levels = c("open", "closed"))
        rep_data$behavior   <- factor(rep_data$cond)
        
        if (npeak == 1){
          plot_lim      = c(-2,2)
        } else if (npeak == 2){
          plot_lim      = c(-1,1)
        }
        
        if (ncom == 1){
          colormap      = c("#8856a7","#31a354")
        } else if (ncom == 2){
          colormap      = c("#c51b8a","#a8ddb5")
        }
        
        round_val <- 3
        
        model_beh         <- lme4::lmer(var ~ (eye+behavior)^2 + (1|sub), data =rep_data)
        model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
        
        pval1 <- round(model_beh_anova$`Pr(>F)`[1],round_val)
        pval2 <- round(model_beh_anova$`Pr(>F)`[2],round_val)
        pval3 <- round(model_beh_anova$`Pr(>F)`[3],round_val)

        emmeans(model_beh, pairwise ~ behavior|eye)
        sumrepdat         <- summarySE(rep_data, measurevar = "var", groupvars=c("eye","behavior"))
        
        p1                <- ggplot(rep_data, aes(x = eye, y = var, fill = behavior))+
          geom_boxplot(aes(x = eye, y = var, fill = behavior),outlier.shape = NA, 
                       alpha = .5, width = .5, colour = "black")+
          scale_fill_manual(values=colormap)+
          scale_color_manual(values=colormap)+
          ggtitle(paste0("p(behavior) = ",pval2,"\n","p(eye) = ",pval1,"\n","p(interaction) = ",pval3))+
          theme_pubclean(base_size = font_s,base_family = "Calibri")+
          scale_y_continuous(name = paste0(list_peak[npeak]," ",list_name[nlevel]),limits = plot_lim)+
          scale_x_discrete(name = list_roi[nroi])
        
        i                 <- i+1
        myplots[[i]]      <- p1
        
        
      }
    }
    
    
    if (length(myplots) > 0){
      grid.arrange(grobs = myplots, ncol = 2,nrow,2)
    }
    
  }
}