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
fname               <- paste0(dir_file,"eyes_visualvirt_stimlock_behav2fft.csv")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table           <- sub_table[sub_table$window == "stim500pre",]

sub_table           <- sub_table[sub_table$roi == "V1d" | sub_table$roi == "V1v" |
                                 sub_table$roi == "V2v" | sub_table$roi == "V2d" |
                                   sub_table$roi == "V3a" | sub_table$roi == "V3b" |
                                   sub_table$roi == "V3d" | sub_table$roi == "V3v",]

# sub_table           <- sub_table[sub_table$roi == "Brodmann area 17" |
#                                    sub_table$roi == "Brodmann area 18" |
#                                    sub_table$roi == "Brodmann area 19",]

# sub_table           <- sub_table[sub_table$roi == "fft visual",]

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$eye       <- as.factor(sub_table$eye)
sub_table$cond      <- as.factor(sub_table$cond)
sub_table$roi       <- as.factor(sub_table$roi)
sub_table$compare   <- as.factor(sub_table$compare)
sub_table$window    <- as.factor(sub_table$window)

list_compare        <- c("accuracy_e","rt")
list_maps           <- c("Dark2","Dark2")

myplots             <- list()
i                   <- 0

for (ncom in 1:length(list_compare)){
  
  rep_data            <- sub_table[sub_table$compare == list_compare[ncom],]
  rep_data$var        <- rep_data$value
  rep_data$eye        <- ordered(rep_data$eye, levels = c("open", "closed"))
  rep_data$cond       <- factor(rep_data$cond)
  
  model_beh           <- lme4::lmer(var ~ (eye+cond+roi)^3 + (1|sub), data =rep_data)
  model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  # model_beh           <- lme4::lmer(var ~ (eye+cond)^2 + (1|sub), data =rep_data)
  # model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
  # print(model_beh_anova)
  
  emmeans(model_beh, pairwise ~ cond|eye)
  
  sumrepdat           <- summarySE(rep_data, measurevar = "var", groupvars=c("eye","cond"))

  pval2 <- round(model_beh_anova$`Pr(>F)`[2],3)
  pval3 <- round(model_beh_anova$`Pr(>F)`[4],3)
  
  p1                  <- ggplot(rep_data, aes(x = eye, y = var, fill = cond))+
    geom_boxplot(aes(x = eye, y = var, fill = cond),outlier.shape = NA, 
                 alpha = .5, width = .5, colour = "black")+
    scale_colour_brewer(palette = list_maps[ncom])+
    scale_fill_brewer(palette = list_maps[ncom])+
    ggtitle(paste0("p(cond) = ",pval2,"\n",
                   "p(eye*cond) = ",pval3))+
    theme_pubclean(base_size = 12,base_family = "Calibri")+
    scale_y_continuous(name = "normalised visual alpha",limits=c(-1,2))+
    scale_x_discrete(name = "")
   
  i                   <- i+1
  myplots[[i]]        <- p1
  
}

grid.arrange(grobs = myplots, ncol = 2,nrow,1)