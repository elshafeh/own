library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "BigCovariance.RoiByTimeByFreq.txt"
fname = paste0(ext1,ext2, collapse = NULL)
pat   = read.table(fname,header=T)

pat   = pat[pat$TIME != "200ms",]
pat   = pat[pat$TIME != "300ms",]
pat   = pat[pat$TIME != "400ms",]
pat   = pat[pat$TIME != "500ms",]
pat   = pat[pat$TIME != "1000ms",]
pat   = pat[pat$TIME != "1100ms",]

model.pat <- lme4::lmer(POW ~ (COND+ROI+FREQ+TIME)^4 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|ROI))

subpat = pat[pat$ROI=="aud.R",]
model.subpat <- lme4::lmer(POW ~ (COND+TIME)^2 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "COND"))