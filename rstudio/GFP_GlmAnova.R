# CnV

library(ez)
library(car)
rm(list=ls())

ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
ext2  = "../txt/New.NLR.CnD.GFP.100msWindow.txt";

fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(GFP ~ (COND*COMP) + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  "COND"))