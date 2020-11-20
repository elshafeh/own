library(ez)
library(car)
rm(list=ls())

ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
ext2  = "BigCovariance.HemiByModByTimeByFreq.Correlation.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(CORR ~ (COND+MODALITY+HEMI+FREQ+TIME)^4 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)