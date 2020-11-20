#-------------------#
#for behavioral data#
#-------------------#
library(ez)
library(car)
library(lsr)
rm(list=ls())
pat=read.table("/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/R/doc/PrepAtt2_TensorPac.txt",header=T)

pat = pat[pat$TIME != 'm400m200' ,]
pat = pat[pat$TIME != 'm200m0' ,]
pat = pat[pat$TIME != 'p0p200' ,]
pat = pat[pat$TIME != 'p200p400' ,]
pat = pat[pat$TIME != 'p400p600' ,]
pat = pat[pat$TIME != 'p1400p1600' ,]
pat = pat[pat$TIME != 'p1600p1800' ,]

pat = pat[pat$CHAN != 'audL' ,]
pat = pat[pat$CHAN != 'RIPS' ,]

pat$CHAN <- factor(pat$CHAN)
pat$TIME <- factor(pat$TIME)

model.pat <- lme4::lmer(PAC ~ (CUE) + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic = c("F"))
print(a)

x <- lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE"),details= TRUE)
print(x)

b <- ezANOVA(pat,dv=.(PAC),wid = .(SUB),within = .(CUE,TIME),detailed=T,type=1)
print(b)