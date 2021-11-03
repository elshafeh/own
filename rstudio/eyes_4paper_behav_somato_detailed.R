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
pd          <- position_dodge(0.1)
alphalev    <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

dir_file          <- "/Users/heshamelshafei/gitHub/own/doc/"
ext_peak          <- "sensor"

fname             <- paste0(dir_file,"eyes.virtualelectrode.all.",ext_peak,".peaks.500pre.csv")
alldata           <- read.table(fname,sep = ',',header=T)

alldata           <- alldata[alldata$band == "alpha" &  alldata$measure == "somato lateralisation index",]

alldata$sub       <- as.factor(alldata$sub)
alldata$eyes      <- as.factor(alldata$eyes)
alldata$measure   <- as.factor(alldata$measure)
alldata$roi       <- as.factor(alldata$roi)
alldata$cond      <- as.factor(alldata$cond)
alldata$compare   <- as.factor(alldata$compare)
alldata$window    <- as.factor(alldata$window)
alldata$peak      <- as.factor(alldata$peak)
alldata$band      <- as.factor(alldata$band)

alldata$eye        <- ordered(alldata$eye, levels = c("open", "closed"))

list_compare      <-  c("accuracy_e","rt") # 
ncom = 2

for (ncom in 1:length(list_compare)){
  
  rep_data            <- alldata[alldata$compare == list_compare[ncom],]
  rep_data$var        <- rep_data$value
  rep_data$behavior   <- factor(rep_data$cond)
  
  plot_lim            <- c(-1,1)
  
  colormap            <- c("#8856a7","#43a2ca")
  round_val           <- 3
  
  model_beh         <- lme4::lmer(var ~ (eye+behavior)^2 + (1|sub), data =rep_data)
  model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,behavior)
  )
  print(e_anova$ANOVA)
  
  map_name            <- c("#8856a7","#43a2ca")
  
  
  pplot <- ggplot(rep_data, aes(x = eye, y = var, fill = behavior)) +
    geom_flat_violin(aes(eye),position = position_nudge(x = .2, y = 0), adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
    geom_boxplot(alpha = .5, width = .35, colour = "black")+
    scale_colour_manual(values= map_name)+
    scale_fill_manual(values = map_name)+
    scale_y_continuous(name = 'Lateralisation index',limits = c(-1,1),
                       breaks=c(-3,-2,-1,0,1,2,3))+
    ggtitle(list_compare[ncom])+
    theme_pubclean(base_size = 16,base_family = "Calibri")
  
  if (ncom == 1){
    p1  = pplot
  } else if (ncom == 2){
    p2 = pplot
  }
  
}

fullfig <- ggarrange(p1,p2,ncol=2,nrow=1)
ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/presentations/eyes2021/_svg/eyes_lateral_alpha.svg",
       plot=fullfig,width=6,height=4)
fullfig
