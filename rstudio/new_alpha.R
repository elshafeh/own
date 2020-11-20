library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

cbPalette <- c( "#009E73","#E69F00","#999999")

ext1        <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "new_alpha.txt" 

pat         <-  read.table(paste0(ext1,ext2),header=T)

sub_pat <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$FREQ == "13Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)#+theme_classic()

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("09Hz", "13Hz"))