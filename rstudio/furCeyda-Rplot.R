# Initiate Libraries ####
# if packages are not installed ; you can do so via install.packages('package_name')
# not sure if they're all necessary though :)

library(dae)
library(nlme)
library(effects)
library(psych)
library(interplot)
library(plyr)
library(devtools)
library(ez)
library(Rmisc)
library(wesanderson)
library(lme4)
library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(dplyr)

##### PLOT Threshold average #####

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/project_ade/Analysis/Behavioral/scripts_r/ade2R_threshold.txt",sep = ',',header=T)

tgc         <- summarySE(ade_table, measurevar="threshold", groupvars=c("side","design","mod")) # calculate confidence measures

ggplot(tgc, aes(x=design, y=threshold,colour=side,group=side)) + 
  geom_errorbar(aes(ymin=threshold-se, ymax=threshold+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+
  theme_bw()+
  facet_wrap(~mod) # line to separate plots
          