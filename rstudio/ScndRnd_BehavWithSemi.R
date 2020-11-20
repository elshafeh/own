library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())
ext1           <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2           <- "ageing_RT_esemi.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

model1.pat      <- lme4::lmer(MedianRT ~ SEMI+ (1|SUB), data =pat)

pd <- position_dodge(0.1) # move them .05 to the left and right

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("SEMI"))

p1 = ggplot(pat, aes(x=SEMI, y=MedianRT)) +
  geom_boxplot()+
  ylim(300,900)+
  theme_classic()

tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("SEMI"))

p2 = ggplot(pat, aes(x=SEMI, y=PerIncorrect)) +
  geom_boxplot()+
  ylim(0,15)+
  theme_classic()

ggarrange(p1, p2,ncol = 2, nrow = 1,common.legend = TRUE)