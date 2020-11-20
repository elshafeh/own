library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)


rm(list=ls())
pd <- position_dodge(0.1) # move them .05 to the left and right

ext1           <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/"
ext2           <- "allyoungcontrol_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

tgc_sub <- summarySE(pat, measurevar="MedianRT", groupvars=c("SUB","DIS"))

ggplot(tgc_sub, aes(x=DIS, y=MedianRT,color=SUB,group=SUB)) + 
  geom_point(position=pd, size=3)+
  geom_line() +
  theme_minimal()+
  ylim(300,1000)

ext1           <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/r_data/"
ext2           <- "Scndround_BehavEffectVar.txt" 
pat            <-  read.table(paste0(ext1,ext2),sep = ',',header=T)

p1 = ggplot(pat, aes(x=sub, y=-arousal)) + 
  geom_point(position=pd, size=3)+
  theme_bw()+ylim(-20,100)

p2= ggplot(pat, aes(x=sub, y=capture)) + 
  geom_point(position=pd, size=3)+
  theme_bw()+ylim(-20,100)

ggarrange(p1, p2,ncol = 1, nrow = 2,labels = c("", ""))
