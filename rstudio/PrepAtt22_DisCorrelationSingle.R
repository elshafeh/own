library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(Hmisc)
library(wesanderson)

rm(list=ls())

ext1    <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/";
ext2    <- "AllyoungControl_DisCorrelation4R.csv"
fname   <- paste0(ext1,ext2, collapse = NULL)
pat     <- read.table(fname,header=T,sep=";")

new_pat <- reshape(pat,direction="wid",idvar=c("SUB","medianCapture","meanCapture","medianTD","meanTD", "medianArousal","meanArousal"),timevar = "ROI")

final_pat <- data.matrix(new_pat)

M         <- cor(final_pat, use = "everything",method="spearman") #na.or.complete") #### tu rentres les donn??es sous format "Excel"
N         <- rcorr(as.matrix(final_pat)) ### ca calcule les p-values

p_table               = N$P
mask                  = p_table < 0.05
mask                  = mask *1 
r_table               = M
mask_table            = mask * r_table
mask_table            = data.frame(mask_table)
mask_table            = mask_table[,c(1:7)];

sub_pat   = pat[pat$ROI=="ladLPFC",]

ggplot(sub_pat,aes(x=disGamma,y =meanCapture)) +
  geom_point() +
  geom_smooth(method = lm)