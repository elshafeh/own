library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)

rm(list=ls())
fname = "/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/R/doc/PrepAtt22_TrialCount.csv"
behav_summary <- read.table(fname,header=T, sep=";")

group_anova <- ezANOVA(behav_summary,dv=.(NTRIAL),wid = .(SUJ),within = .(CUE,DIS),between = (GROUP),detailed=T)
print(group_anova)

tgc <- summarySE(behav_summary, measurevar="NTRIAL", groupvars=c("CUE","DIS","GROUP"))

pd <- position_dodge(0.05)

interaction.ABC.plot(NTRIAL, x.factor=DIS,
                     groups.factor=CUE, trace.factor=GROUP,
                     data=behav_summary, c,ggplotFunc=list(ylim(0,60),geom_errorbar(data=tgc,
                                                                                aes(ymax=NTRIAL+se, ymin=NTRIAL-se),width=0.2)))

