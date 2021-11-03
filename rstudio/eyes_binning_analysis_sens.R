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

source("/Users/heshamelshafei/Dropbox/project_me/data/eyes/twolines.r")

data.example=read.csv("/Users/heshamelshafei/Dropbox/project_me/data/eyes/example.csv")

dir_file              <- "/Users/heshamelshafei/Dropbox/project_me/doc/R/"
fname                 <- paste0(dir_file,"eyes.sens.binning.","2","bin.","0.5s",".csv")
alldata               <- read.table(fname,sep = ',',header=T)

alldata               <- alldata[alldata$measure == "lat",] # absolute relative lat
  
alldata$sub           <- as.factor(alldata$sub)
alldata$eye           <- as.factor(alldata$eye)
alldata$bin           <- as.factor(alldata$bin)
alldata$eye           <- ordered(alldata$eye, levels = c("open", "closed"))

list_measure          <- c("accuracy","mean rt","median rt")

for (ncom in 1:length(list_measure)){
  
  if (ncom == 1){
    rep_data          <- alldata
    rep_data$var      <- rep_data$perc
    plot_lim          <- c(0.4,1)
    intercept = 0.5
  } else if (ncom == 2){
    rep_data          <- alldata
    rep_data$var      <- rep_data$rt_median
    plot_lim          <- c(0.4,1)
    intercept = 0
  } else if (ncom == 3){
    rep_data          <- alldata
    rep_data$var      <- rep_data$rt_mean
    plot_lim          <- c(0.4,1)
    intercept = 0
  }
  
  print(list_measure[ncom])
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,bin)
  )
  print(e_anova$ANOVA)
  
  list_eyes           <- c("open","closed")
  
  for (neyes in 1:length(list_eyes)){
    
    sub_data <- rep_data[rep_data$eye == list_eyes[neyes],]
    sub_data$eyes      <- as.factor(sub_data$eye)
    
    pplot <- ggplot(sub_data, aes(x = bin, y = var, fill = bin)) +
      geom_line(aes(group=sub),color='gray',size=0.2,alpha=0.6)+
      geom_point(alpha = .5,size=1)+
      geom_boxplot(alpha = .5, width = .35, colour = "black")+ 
      ggtitle(paste0(list_measure[ncom]," and ",unique(alldata$measure),": ",list_eyes[neyes]))+
      scale_x_discrete(name = list_eyes[neyes])+
      scale_y_continuous(name = "",limit = plot_lim)+
      # scale_y_continuous(name = "")+
      theme_pubr(base_size = 12,base_family = "Calibri")+
      guides(fill=FALSE,color = FALSE, size = FALSE)+
      geom_hline(yintercept = intercept, linetype="dashed")
    
    if (ncom == 1 & neyes == 1){
      p1  = pplot
    } else if (ncom == 1 & neyes == 2){
      p2 = pplot
    } else if (ncom == 2 & neyes == 1){
      p3 = pplot 
    } else if (ncom == 2 & neyes == 2){
      p4 = pplot 
    } else if (ncom == 3 & neyes == 1){
      p5 = pplot 
    } else if (ncom == 3 & neyes == 2){
      p6 = pplot 
    }
    
  }
  
}

fullfig <- ggarrange(p1,p2,p3,p4,p5,p6,ncol=2,nrow=3)
fullfig


