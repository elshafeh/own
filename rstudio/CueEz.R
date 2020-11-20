library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "BigCovariance.HemiByModByTimeByFreq4Ez.txt"
fname = paste0(ext1,ext2, collapse = NULL)
pat   = read.table(fname,header=T)
pat   = pat[pat$MODALITY = "aud",]
a = ezANOVA (pat, dv = .(POW), wid = .(SUB), within= .(COND,HEMI,FREQ), detailed=T)
print(a)