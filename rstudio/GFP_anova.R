library(ez)
library(car)
rm(list=ls())

pat = read.table("/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/4cst.nDT.GFP.txt",header=T)

model.pat <- lme4::lmer(GFP ~ (COND+COMP)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2);print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "COND"))
lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~COND|COMP))

ez  = ezANOVA (pat, dv = .(GFP), wid = .(SUB), within= .(COND,COMP), detailed=T,type=1)
print(ez)