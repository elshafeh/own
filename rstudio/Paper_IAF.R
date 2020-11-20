library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
ext2  = "BigCovariance.IAFWithCue.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(VAL ~ (COND+HEMI+MODALITY)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~COND|MODALITY))

########################################################################
########################################################################
########################################################################

rm(list=ls())
ext1  = "/Users/heshamelshafei/Dropbox/Fieldtripping/txt/";
ext2  = "BigCovariance.HemiByModByFreq.Early.IAF4Paper.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(VAL ~ (HEMI+MODALITY)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~HEMI))
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~MODALITY))