library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/Desktop/"
ext2           <- "informative_gain.csv" 
pat            <-  read.table(paste0(ext1,ext2),header=T,sep=';')

pd <- position_dodge(0.5) # move them .05 to the left and right

tgc <- summarySE(pat, measurevar="CUE_GAIN", groupvars=c("GROUP"))

ggplot(tgc, aes(x=GROUP, y=CUE_GAIN)) + 
  geom_errorbar(aes(ymin=CUE_GAIN-se, ymax=CUE_GAIN+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3, shape=21, fill="white")+ylim(0, 30)+theme_classic()# 21 is filled circle

, colour=GROUP, group=GROUP