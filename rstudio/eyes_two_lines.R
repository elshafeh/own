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

dir_file              <- "~/github/own/doc/"
fname                 <- paste0(dir_file,"eyes.sens.binning.csv")
alldata               <- read.table(fname,sep = ',',header=T)


alldata               <- alldata[alldata$measure == "lat",] # absolute relative lat

alldata$sub           <- as.factor(alldata$sub)
alldata$eye           <- as.factor(alldata$eye)
alldata$bin           <- as.factor(alldata$bin)
alldata$eye           <- ordered(alldata$eye, levels = c("open", "closed"))

list_measure          <- c("accuracy","rt")
list_eyes             <- c("open","closed")

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
  
  for (neyes in 1:length(list_eyes)){
    
    sub_data <- rep_data[rep_data$eye == list_eyes[neyes],]
    sub_data$eyes      <- as.factor(sub_data$eye)
    
    a         <- twolines(var~bin_n,data=sub_data)
    title(paste0(list_eyes[neyes]," ",list_measure[ncom]))
    
  }
  
}

# fullfig <- ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)
# fullfig


