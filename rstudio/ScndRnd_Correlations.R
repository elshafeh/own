# Initiate Libraries ####

library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
pd          <- position_dodge(0.1)


### ---- virtual 
### ---- dics transform

fname1      <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/r_data/"
fname2      <- "Scndround_pat22DIS_4correlation_flinecorrected.txt"

all_table   <- read.table(paste0(fname1,fname2),sep = ',',header=T)

#cuebenefit arousal capture

ggscatter(all_table, x = "capture", y = "disPOW", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "spearman")+facet_wrap(~roi)

ggscatter(all_table, x = "cuebenefit", y = "dis2m1", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "spearman")+facet_wrap(~roi)





