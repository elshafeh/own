#Gamma: DELAY#
library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "DIS123.Gamma.PreCueCorrection.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(POW ~ (COND+FREQ+TIME)^2+ (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "COND"))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|TIME))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|FREQ))

sub_pat       = pat[pat$CHAN == "audR",]
sub_model.pat <- lme4::lmer(POW ~ (COND+TIME)^2 + (1|SUB), data =sub_pat)
sub_a         <-Anova(sub_model.pat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat, pairwise~COND|TIME))

#------------------------------------------------------------------------------------#

#GAMMA: CUE*DELAY#
library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "DIS.CueByDelay.Gamma.TimeFreq.PreCueCorrection.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(POW ~ (CUE+DELAY+FREQ+TIME)^3 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "DELAY"))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE|DELAY))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~DELAY|TIME))

#------------------------------------------------------------------------------------#

rm(list=ls())
ext1    = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2    = "PrepAtt2.medianRT.txt"
fname   = paste0(ext1,ext2, collapse = NULL);
behav   = read.table(fname,header=T)

model.pat <- lme4::lmer(medianRT ~ (CUE+DIS)^2 + (1|SUB), data =behav)
a         <-Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "DIS"))