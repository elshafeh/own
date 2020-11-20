library(ez)
library(car)

pat = read.table("/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/GammaDT.latEffect.txt",header=T)

model.pat <- lme4::lmer(POW ~ (LATENCY+DELAY)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2);
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "DELAY"))
lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~COND|CHAN))
