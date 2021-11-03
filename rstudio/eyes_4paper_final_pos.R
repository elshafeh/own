library(cowplot)
library(dplyr)
library(readr)
library(ggpubr)
library(lme4)
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

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

alldata           <- read.table("/Users/heshamelshafei/Dropbox/project_me/data/eyes/doc/eyes_pos_compare.csv",header=T,sep = ',')
alldata$sub       <- as.factor(alldata$sub)
alldata$effect    <- as.factor(alldata$effect)

# alldata$eye       <- ordered(alldata$eye, levels = c("open", "closed"))

pd                <- position_dodge(0.1)

erbar_w           <- .08
erbar_s           <- .5
scat_s            <- 1.5
mean_s            <- 2.5
font_s            <- 16

title_names       <- c("","")
axes_names        <-c("x","y","z")

for (nvar in c(1,2,3)){
  
  if (nvar == 1){
    rep_data      <- alldata
    rep_data$var  <- rep_data$xpos
    plot_lim <- c(-6,6)
  } else if (nvar == 2){
    rep_data      <- alldata
    rep_data$var  <- rep_data$ypos
    plot_lim <- c(-11,-6)
  } else if (nvar == 3){
    rep_data      <- alldata
    rep_data$var  <- rep_data$zpos
    plot_lim <- c(-2,6)
  }
  
  res             <- t.test(var ~ effect, data = rep_data,paired=TRUE)
  print(res)
  
  val_round <- 3
  pval1 <- round(res$p.value,val_round)
  
  # map_name  <- c("#FF7F00","#33A02C")
  
  pplot <- ggplot(rep_data, aes(x = effect, y = var, fill = effect)) +
    # geom_flat_violin(aes(eye),position = position_nudge(x = .2, y = 0), adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
    geom_line(aes(group=sub),color='gray',size=0.2,alpha=0.6)+
    geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
    # scale_colour_manual(values= map_name)+
    # scale_fill_manual(values = map_name)+
    ggtitle(paste0("p = ",pval1))+
    scale_y_continuous(name = axes_names[nvar],limits = c(plot_lim[1], plot_lim[2]))+
    scale_x_discrete(name = "")+ #,labels = c("open" , "closed"))+
    theme_pubr(base_size = font_s,base_family = "Calibri")+
    guides(fill=FALSE,color = FALSE, size = FALSE)
  
  if (nvar == 1){
    p1  = pplot
  } else if (nvar == 2){
    p2 = pplot
  } else if (nvar == 3){
    p3 = pplot 
  }
  
}

fullfig <- ggarrange(p1,p2,p3,ncol=3,nrow=1)
fullfig

ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/figures/eyes/eyes_pos.SVG",
       plot=fullfig,width=6,height=2.5)
