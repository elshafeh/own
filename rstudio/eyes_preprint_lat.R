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
pd                    <- position_dodge(0.1)
alphalev              <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

dir_file              <- "/Users/heshamelshafei/Dropbox/project_me/doc/R/"
fname                 <- paste0(dir_file,"eyes.behav2fft.sensor.lat.","1","s.","new",".csv")
alldata               <- read.table(fname,sep = ',',header=T)
alldata               <- alldata[alldata$measure == "somato lateralisation index",]

alldata$sub           <- as.factor(alldata$sub)
alldata$eyes          <- as.factor(alldata$eyes)
alldata$compare       <- as.factor(alldata$compare)
alldata$behavior      <- as.factor(alldata$cond)

alldata$eye           <- ordered(alldata$eye, levels = c("open", "closed"))
list_compare          <-  c("accuracy_e","rt") # "accuracy", 

for (ncom in 1:length(list_compare)){
  
  rep_data            <- alldata[alldata$compare == list_compare[ncom],]
  rep_data$behavior   <- factor(rep_data$behavior)
  rep_data$var        <- rep_data$value
  
  colormap            <- c("#8856a7","#43a2ca")
  round_val           <- 3
  
  print(list_compare[ncom])
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,behavior)
  )
  print(e_anova$ANOVA)
  
  map_name            <- c("#8856a7","#43a2ca")
  list_eyes           <- c("open","closed")
  
  for (neyes in 1:length(list_eyes)){
    
    sub_data <- rep_data[rep_data$eye == list_eyes[neyes],]
    sub_data$eyes      <- as.factor(sub_data$eyes)
    
    limit_acc <- c(-0.25,0.4) # c(-0.8,2)#
    limit_rt <- c(-0.1,0.2) #limit_open#
    
    if (ncom == 1){
      
      if (neyes == 1){plot_lim <- c(-0.3,0.3)}
      if (neyes == 2){plot_lim <- c(-0.2,0.3)}
      plot_break <- c(-0.3,-0.2,-0.1,0,0.1,0.2,0.3)
      
      
    } else if (ncom == 2){
      plot_lim <- c(-0.1,0.2)
    }
    
    pplot <- ggplot(sub_data, aes(x = behavior, y = var, fill = behavior)) +
      geom_line(aes(group=sub),color='gray',size=0.2,alpha=0.6)+
      # geom_boxplot(alpha = .5, width = .35, colour = "black")+
      geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
      scale_colour_manual(values= map_name)+
      scale_fill_manual(values = map_name)+
      ggtitle(list_compare[ncom])+
      scale_y_continuous(name = "",limits = plot_lim,breaks = plot_break)+
      scale_x_discrete(name = list_eyes[neyes])+
      # ,labels = c("open" , "closed"))+
      theme_pubr(base_size = 13,base_family = "Calibri")+
      guides(fill=FALSE,color = FALSE, size = FALSE)
    
    if (ncom == 1 & neyes == 1){
      p1  = pplot
    } else if (ncom == 1 & neyes == 2){
      p3 = pplot
    } else if (ncom == 2 & neyes == 1){
      p2 = pplot 
    } else if (ncom == 2 & neyes == 2){
      p4 = pplot 
    } else if (ncom == 3 & neyes == 1){
      p5 = pplot 
    } else if (ncom == 3 & neyes == 2){
      p6 = pplot 
    }
    
  }
}

if (ncom == 3){
  fullfig <- ggarrange(p1,p3,p2,p4,p5,p6,ncol=2,nrow=3)
} else if (ncom == 2){
  fullfig <- ggarrange(p1,p3,p2,p4,ncol=4,nrow=1)
} else if (ncom == 1){
  fullfig <- ggarrange(p1,p3,ncol=2,nrow=1)
}

fullfig

ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/figures/eyes/eyes_jun_final_lat.svg",
       plot=fullfig,width=10,height=3)

# find_outlier          <- alldata[alldata$behavior == "incor_e" &
#                                    alldata$eyes == "closed" &
#                                    alldata$value > 0.2,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# bad_suj

# bad_suj               <- c("sub012","sub017")
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# # alldata$sub           <- factor(alldata$sub)
