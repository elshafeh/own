library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
ext2  = "BigCovariance.NoHemiNewEvokedPost.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

pat = pat[pat$FREQ != "5Hz",]
pat = pat[pat$FREQ != "6Hz",]

model.pat <- lme4::lmer(POW ~ (COND+FREQ+TIME)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat,  "COND"))


ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
ext2  = "TargetGamma.NoHemi.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)
model.pat <- lme4::lmer(POW ~ (COND+FREQ+TIME)^3 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat,  "COND"))
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~COND|FREQ))

