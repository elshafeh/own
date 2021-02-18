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

dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/eyes.corinne."

list_measure        <- c("acc","rt")
list_variable       <- c("vis","index")
list_name           <- c("normalised visual\nalpha power","Lateralization Index")

myplots             <- list()
i                   <- 0

for (nm in 1:length(list_measure)){
  for (nv in 1:length(list_variable)){
    
    fname             <- paste0(dir_file,list_measure[nm],'.',list_variable[nv],'.txt')
    sub_table         <- read.table(fname,sep = ',',header=T)
    
    sub_table$var     <- sub_table[,4]
    sub_table$sub     <- as.factor(sub_table$suj)
    sub_table$eye     <- as.factor(sub_table$eyes)
    
    if (nm == 1){
      sub_table$cond    <- as.factor(sub_table$perf)
    } else if (nm == 2){
      sub_table$cond    <- as.factor(sub_table$rt)
    }
    
    rep_data          <- sub_table[,c(6,7,8,5)]
    rep_data$eye      <- ordered(rep_data$eye, levels = c("open", "closed"))
    
    model_beh         <- lme4::lmer(var ~ (eye+cond)^2 + (1|sub), data =rep_data)
    model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
    
    e_anova = ezANOVA(
      data = rep_data
      , dv = .(var)
      , wid = .(sub)
      , within = .(eye,cond)
    )
    
    # pval1 <- round(model_beh_anova$`Pr(>F)`[1],2)
    # pval2 <- round(model_beh_anova$`Pr(>F)`[2],2)
    # pval3 <- round(model_beh_anova$`Pr(>F)`[3],2)
    
    round_val <- 3
    pval1 <- round(e_anova$ANOVA$p[1],round_val)
    pval2 <- round(e_anova$ANOVA$p[2],round_val)
    pval3 <- round(e_anova$ANOVA$p[3],round_val)
    
    sumrepdat         <- summarySE(rep_data, measurevar = "var", groupvars=c("eye","cond"))
    
    p1                <- ggplot(rep_data, aes(x = cond, y = var, fill = eye))+
      geom_boxplot(aes(x = cond, y = var, fill = eye),outlier.shape = NA, 
                   alpha = .5, width = .5, colour = "black")+
      scale_colour_brewer(palette = "Dark2")+
      scale_fill_brewer(palette = "Dark2")+
      ggtitle(paste0("p(eye) = ",pval1,"\n",
                     "p(behavior) = ",pval2,"\n",
                     "p(interaction) = ",pval3))+
      scale_y_continuous(name = list_name[nv])+
      scale_x_discrete(name = "")+
      theme_pubclean(base_size = 12,base_family = "Calibri")
    
    i                 <- i+1
    myplots[[i]]      <- p1
    
  }
}

grid.arrange(grobs = myplots, ncol = 2,nrow,2)