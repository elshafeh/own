library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())
pd <- position_dodge(0.1) # move them .05 to the left and right

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "brain_topo_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

tgc            <- summarySE(pat, measurevar="MedianRT", groupvars=c("cond_cue","cond_dis"))

low_limit      = 200
hi_limit       = 200
by_break       = 20
# ylim1          <- min(pat$MedianRT) - low_limit
# ylim2          <- max(pat$MedianRT) + hi_limit

ylim1          <- 100 # round(mean(pat$MedianRT) - low_limit)
ylim2          <- 700 # round(mean(pat$MedianRT) + hi_limit)

p1             <- ggplot(tgc, aes(x=cond_dis, y=MedianRT, colour=cond_cue,group=cond_cue)) + 
  geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21, fill="white") +ylim(ylim1, ylim2)

pat = read.table("/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/Old/Old/PrepAtt2.medianRT.txt",header=T)

pat[pat$CUE=="L" | pat$CUE=="R",5] = 'Valid'
pat[pat$CUE=="N",5] = 'Neutral'

names(pat) <- c("SUB","CUE", "DIS","MedianRT","cue_group")
pat$cue_group = factor(pat$cue_group)

# model.pat      <- lme4::lmer(medianRT ~ (cue_group+DIS)^2 + (1|SUB), data =pat) # PerCorrect
# model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
# print(model_anova)
# lsmeans::cld(lsmeans::lsmeans(model.pat,  "DIS"),details= TRUE)
# x =lsmeans(model.pat,  "DIS",details= TRUE)

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("cue_group","DIS"))

# ylim1          <- 150 # round(mean(pat$MedianRT) - low_limit)
# ylim2          <- 650 # round(mean(pat$MedianRT) + hi_limit)

p2 = ggplot(tgc, aes(x=DIS, y=MedianRT, colour=cue_group,group=cue_group)) + 
  geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21, fill="white") +ylim(ylim1, ylim2)

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "allyoungcontrol_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE_CAT","DIS"))

# ylim1          <- 150 # round(mean(pat$MedianRT) - low_limit)
# ylim2          <- 650 # round(mean(pat$MedianRT) + hi_limit)

p3 = ggplot(tgc, aes(x=DIS, y=MedianRT, colour=CUE_CAT,group=CUE_CAT)) + 
  geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21, fill="white") +ylim(ylim1, ylim2)

ggarrange(p1, p2,p3,ncol = 3, nrow = 1)
