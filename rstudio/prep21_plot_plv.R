library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

cbPalette <- c( "#56B4E9","#999999", "#E69F00")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "prep21_plv2plot.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_COND","CHAN"))

ggplot2::ggplot(tgc, aes(x=CHAN, y=POW, fill=CUE_COND)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.25,0.25)+scale_fill_manual(values=cbPalette)+theme_classic()
