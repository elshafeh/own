library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "PrepAtt22_ageing_demog.csv" 
pat            <-  read.table(paste0(ext1,ext2),header=T,sep = ';')

res <- t.test(pat[pat$GROUP=='old',"AGE"], pat[pat$GROUP=='young',"AGE"])
res

res <- t.test(pat[pat$GROUP=='old',"EDU"], pat[pat$GROUP=='young',"EDU"])
res

res <- t.test(pat[pat$GROUP=='old',"MUSIC"], pat[pat$GROUP=='young',"MUSIC"])
res

tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("EDU","GROUP","MUSIC"))
