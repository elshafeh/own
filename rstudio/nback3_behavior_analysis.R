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

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")

col_map             <- "Dark2"
erbar_w             <- .6; erbar_s <- .8; pd  <- position_dodge(erbar_w+.1)
scat_s              <- 1.5;mean_s  <- 5; font_s  <- 16
plot_breaks         <- seq(plot_lim[1],plot_lim[2],by = 0.02)

dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/"
fname               <- paste0(dir_file,"nback3_behav_data.csv")

sub_table           <- read.table(fname,sep = ',',header=T)

sub_table           <- sub_table[sub_table$cond != "0back",]

sub_table$sub       <- as.factor(sub_table$suj)
sub_table$cond      <- as.factor(sub_table$cond)

for (nvar in c(1,2)){

  rep_data      <- sub_table
    
  axes_names    <- c("median RT","% Correct")
  
  if (nvar == 1){
    rep_data$var    <- rep_data$rt
    plot_lim        <- c(0.2,1)
    plot_break      <- c(0.2,0.4,0.6,0.8,1)
  } else if (nvar == 2){
    rep_data$var  <- rep_data$correct
    plot_lim        <- c(92,100)
    plot_break      <- c(92,94,96,98,100) #c(0,2,4,6,8,10) * 10
  }
  
  res             <- t.test(var ~ cond, data = rep_data,paired=TRUE)
  
  val_round <- 3
  pval1 <- round(res$p.value,val_round)
  
  rm(res)
  
  map_name  <- c("#70ba8d","#7098ba")
  
  pplot <- ggplot(rep_data, aes(x = cond, y = var, fill = cond)) +
    geom_point(size = 0.5,color='black')+
    geom_line(aes(group=suj),color='gray',size=0.2,alpha=0.6)+
    geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
    scale_colour_manual(values= map_name)+
    scale_fill_manual(values = map_name)+
    ggtitle(paste0("p(cond) = ",pval1))+
    scale_y_continuous(name = axes_names[nvar],breaks = plot_break,limits = plot_lim)+
    scale_x_discrete(name = "",labels = c("1-Back" , "2-Back"))+
    theme_pubr(base_size = 18,base_family = "Calibri")+
    guides(fill=FALSE,color = FALSE, size = FALSE)
  
  
  if (nvar == 1){
    p1  = pplot
  } else if (nvar == 2){
    p2 = pplot
  }
  
}

fullfig <- ggarrange(p1,p2,ncol=2,nrow=1)
fullfig

# dir_out <- "/Users/heshamelshafei/Dropbox/project_me/papers/postdoc/nback/nback_manuscript_v3/_prep/"
# ggsave(filename=paste0(dir_out,"nback3_behaviors.SVG"),
#        plot=fullfig,width=6,height=3.5)
