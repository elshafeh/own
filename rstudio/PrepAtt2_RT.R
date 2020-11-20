library(ez)
library(car)

pat = pat[pat$DIS == 'D0' ,]

model.pat <- lme4::lmer(medianRT ~ CUE + (1|SUB), data =pat)
a         <- Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "DIS"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "BLOC"))

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE|DIS))