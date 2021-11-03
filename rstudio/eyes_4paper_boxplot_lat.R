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

dir_data <- "/Users/heshamelshafei/Dropbox/project_me/presentations/eyes2021/_doc/"
alldata           <- read.table(paste0(dir_data,"eyes_lat_forbox_june.csv"),header=T,sep = ',')
alldata$suj       <- as.factor(alldata$sub)
alldata$eye       <- as.factor(alldata$eye)
alldata$eye        <- ordered(alldata$eye, levels = c("open", "close"))

pd                <- position_dodge(0.1)

erbar_w           <- .08
erbar_s           <- .5
scat_s            <- 1.5
mean_s            <- 2.5
font_s            <- 16

title_names       <- c("","")
axes_names        <-c("lat index","right")

for (nvar in c(1,2)){
  
  rep_data      <- alldata
  map_name  <- c("#FF7F00","#33A02C")
  
  pplot <- ggplot(rep_data, aes(x = eye, y = pow, fill = eye)) +
    geom_line(aes(group=suj),color='gray',size=0.2,alpha=0.6)+
    geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
    scale_colour_manual(values= map_name)+
    scale_fill_manual(values = map_name)+
    # ggtitle(paste0("p(eye) = ",pval1))+
    scale_y_continuous(name = axes_names[nvar],
                       breaks =c(-0.1,-0.05,0,0.05,0.1,0.15,0.2),
                       limits = c(-0.05,0.15))+
    scale_x_discrete(name = "",labels = c("open" , "closed"))+
    theme_pubr(base_size = font_s,base_family = "Calibri")+
    guides(fill=FALSE,color = FALSE, size = FALSE)
  
  
  if (nvar == 1){
    p1  = pplot
  } else if (nvar == 2){
    p2 = pplot
  }
  
}

# find_outlier          <- alldata[alldata$eye == "open" &
#                                    alldata$pow > 0.14,]
# bad_suj <- as.character(unique(find_outlier$sub))
# bad_suj
# 
# find_outlier          <- alldata[alldata$eye == "open" &
#                                    alldata$pow < -0.04,]
# bad_suj <- as.character(unique(find_outlier$sub))
# bad_suj

fullfig <- ggarrange(p1,p1,ncol=2,nrow=1)
fullfig

ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/figures/eyes/eyes_latboxplot_june.svg",
       plot=fullfig,width=4.5,height=2.1)
