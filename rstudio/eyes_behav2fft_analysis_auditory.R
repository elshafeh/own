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

dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/"
fname               <- paste0(dir_file,"eyes_auditoryvirt_stimlock_behav2fft.csv")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$eye       <- as.factor(sub_table$eye)
sub_table$cond      <- as.factor(sub_table$cond)
sub_table$roi       <- as.factor(sub_table$roi)
sub_table$compare   <- as.factor(sub_table$compare)
sub_table$window    <- as.factor(sub_table$window)

list_compare        <- unique(levels(sub_table$compare)) #c("rt")#
list_window         <- c("stim500pre")#unique(levels(sub_table$window)) # 
list_roi            <- unique(levels(sub_table$roi))

# plot
list_maps           <- c("Dark2","Dark2","Dark2","Dark2")


myplots             <- list()
i                   <- 0

for (nwin in 1:length(list_window)){
  
  for (nroi in 1:length(list_roi)){
    for (ncom in 1:length(list_compare)){
      
      
      
      rep_data          <- sub_table[sub_table$window == list_window[nwin] 
                                     & sub_table$roi == list_roi[nroi] 
                                     & sub_table$compare == list_compare[ncom],]
      rep_data$var      <- rep_data$value
      rep_data$eye      <- ordered(rep_data$eye, levels = c("open", "closed"))
      rep_data$cond     <- factor(rep_data$cond)
      
      
      plot_lim      = c(-0.6,0.6)
      
      model_beh         <- lme4::lmer(var ~ (eye+cond)^2 + (1|sub), data =rep_data)
      model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
      emmeans(model_beh, pairwise ~ cond|eye)
      
      sumrepdat         <- summarySE(rep_data, measurevar = "var", groupvars=c("eye","cond"))
      
      e_anova = ezANOVA(
        data = rep_data
        , dv = .(var)
        , wid = .(sub)
        , within = .(eye,cond)
      )
      
      round_val <- 3
      pval1 <- round(model_beh_anova$`Pr(>F)`[1],round_val)
      pval2 <- round(model_beh_anova$`Pr(>F)`[2],round_val)
      pval3 <- round(model_beh_anova$`Pr(>F)`[3],round_val)
      
      # pval1 <- round(e_anova$ANOVA$p[1],round_val)
      # pval2 <- round(e_anova$ANOVA$p[2],round_val)
      # pval3 <- round(e_anova$ANOVA$p[3],round_val)
      
      if (pval2 < 0.12){
        p1                <- ggplot(rep_data, aes(x = eye, y = var, fill = cond))+
          geom_boxplot(aes(x = eye, y = var, fill = cond),outlier.shape = NA, 
                       alpha = .5, width = .5, colour = "black")+
          scale_colour_brewer(palette = list_maps[nroi])+
          scale_fill_brewer(palette = list_maps[nroi])+
          ggtitle(paste0("p(behavior) = ",pval2,"\n",
                         "p(interaction) = ",pval3))+
          theme_pubclean(base_size = 12,base_family = "Calibri")+
          scale_y_continuous(name = paste0("Auditory\n",list_roi[nroi]),limits = plot_lim)+
          scale_x_discrete(name = list_window[nwin])
        
        i                 <- i+1
        myplots[[i]]      <- p1
      }
      
    }
  }
}


if (length(myplots) > 0){
  grid.arrange(grobs = myplots, ncol = 2,nrow,2)
}
