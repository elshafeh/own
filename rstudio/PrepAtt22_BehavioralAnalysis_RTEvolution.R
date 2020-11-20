library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)

rm(list=ls())

fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_RTEvolution.csv"
behav_summary <- read.table(fname,header=T, sep=";")

pat_age <- behav_summary[behav_summary$Group=="old" | behav_summary$Group=="young",]
pat_age$SUJ <- factor(pat_age$SUJ)

a <- ezANOVA(pat_age,dv=.(MedianRT),wid = .(SUJ),within = .(NBloc),between = (Group),detailed=T)
print(a)

