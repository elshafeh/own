library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
#ext2           <- "prep21_saccade_count.txt"
ext2           <- "prep21_saccade_count2level.txt"

pat            <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(PERC_SAC ~ (CUE+DIRECTION)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

tgc <- summarySE(pat, measurevar="PERC_SAC", groupvars=c("CUE","DIRECTION"))

ggplot2::ggplot(tgc, aes(x=DIRECTION, y=PERC_SAC, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=PERC_SAC-se, ymax=PERC_SAC+se),width=.2,position=position_dodge(.9))+
  ylim(0,4)+theme_classic()
