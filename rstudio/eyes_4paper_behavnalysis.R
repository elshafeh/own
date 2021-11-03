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

alldata           <- read.table("/Users/heshamelshafei/github/own/doc/eyes.behav.fromds.csv",header=T,sep = ',')
alldata$suj       <- as.factor(alldata$suj)
alldata$eye       <- as.factor(alldata$eyes)
alldata$cue       <- as.factor(alldata$cue)
alldata$eye       <- ordered(alldata$eye, levels = c("open", "closed"))

sum_data <- summarySE(data = alldata, groupvars = ("eyes"),measurevar = "rt")
sum_data <- summarySE(data = alldata, groupvars = ("eyes"),measurevar = "perc")

sum_data <- summarySE(data = alldata, measurevar = "rt")
sum_data <- summarySE(data = alldata, measurevar = "perc")


# No interaction was found.

# model_beh         <- lme4::lmer(rt ~ (eyes+cue)^2 + (1|suj), data =alldata)
# model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
# print(model_beh_anova)
# model_beh         <- lme4::lmer(perc ~ (eyes+cue)^2 + (1|suj), data =alldata)
# model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
# print(model_beh_anova)

pd                <- position_dodge(0.1)

erbar_w           <- .08
erbar_s           <- .5
scat_s            <- 1.5
mean_s            <- 2.5
font_s            <- 16

title_names       <- c("","")
axes_names        <-c("Percentage of correct responses","Reaction time (s)")

for (nvar in c(1,2)){
  
  if (nvar == 1){
    rep_data      <- alldata
    rep_data$var  <- rep_data$perc
    plot_lim      = c(50,100,10)
  } else if (nvar == 2){
    rep_data      <- alldata
    rep_data$var  <- rep_data$rt
    plot_lim      = c(0.4,0.9,0.1)
  }
  
  res             <- t.test(var ~ eye, data = rep_data,paired=TRUE)
  print(res)
  
  # coh_d    <- rep_data %>% cohens_d(var ~ eye, paired = TRUE)
  # print(coh_d$effsize)
  
  val_round <- 3
  pval1 <- round(res$p.value,val_round)
  
  map_name  <- c("#FF7F00","#33A02C")
  
  sum_table   <- rep_data %>%
    group_by(suj,eye)%>%
    mutate(var_mean = mean(var)) %>%
    summarise(max(var_mean))
  
  col_names                         = colnames(sum_table);
  col_names[length((col_names))]    = "var";
  names(sum_table)                  = col_names
  
  pplot <- ggplot(sum_table, aes(x = eye, y = var, fill = eye)) +
    geom_line(aes(group=suj),color='gray',size=0.2,alpha=0.6)+
    geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
    scale_colour_manual(values= map_name)+
    scale_fill_manual(values = map_name)+
    ggtitle(paste0("p(eye) = ",pval1))+
    scale_y_continuous(name = axes_names[nvar], breaks =seq(plot_lim[1], plot_lim[2], by = plot_lim[3]),
                       limits = c(plot_lim[1], plot_lim[2]))+
    scale_x_discrete(name = "",labels = c("open" , "closed"))+
    theme_pubr(base_size = font_s,base_family = "Calibri")+
    guides(fill=FALSE,color = FALSE, size = FALSE)
  
  if (nvar == 1){
    p1  = pplot
  } else if (nvar == 2){
    p2 = pplot
  }
  
}

fullfig <- ggarrange(p1,p2,ncol=2,nrow=1)
fullfig

ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/figures/eyes/eyes_june_behavrainclouds.svg",
       plot=fullfig,width=6,height=3.5)


