library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "PrepAtt22_patient_demog.csv" 
pat            <-  read.table(paste0(ext1,ext2),header=T,sep = ';')

names(pat) <- c("SUB","SEX","LAT","AGE","EDU","MUSIC","GROUP")


res <- t.test(pat[pat$GROUP=='patient',"AGE"], pat[pat$GROUP=='control',"AGE"])
res

res <- t.test(pat[pat$GROUP=='patient',"EDU"], pat[pat$GROUP=='control',"EDU"])
res

res <- t.test(pat[pat$GROUP=='patient',"MUSIC"], pat[pat$GROUP=='control',"MUSIC"])
res

tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("EDU","GROUP","MUSIC"))
