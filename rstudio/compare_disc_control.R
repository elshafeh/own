library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "PrepAtt22_Disc_Control.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

tgc <- summarySE(pat, measurevar="DISC_PERC", groupvars=c("GROUP"))

ggplot(tgc, aes(x=GROUP, y=DISC_PERC, fill=GROUP)) + 
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=DISC_PERC-se, ymax=DISC_PERC+se), width=.2,
                position=position_dodge(.9))


sub_pat = pat[pat$GROUP == "gr1" | pat$GROUP == "gr2",]
kruskal.test(DISC_PERC~GROUP,data=spec_test)
