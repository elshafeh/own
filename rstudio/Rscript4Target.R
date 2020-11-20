# ALPHA POST TARGET
library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "/RLN.CnD.PostTarget.alpha.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)
model.pat <- lme4::lmer(POW ~ (COND+CHAN+FREQ+TIME)^4 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|CHAN))

sub_pat       = pat[pat$CHAN == "audR",]
sub_model.pat <- lme4::lmer(POW ~ (COND+FREQ)^2 + (1|SUB), data =sub_pat)
sub_a         <-Anova(sub_model.pat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat, pairwise~COND|FREQ))


#GAMMA#
library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "RLN.NewBsl.nDT.gamma.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)
model.pat <- lme4::lmer(POW ~ (COND+FREQ+TIME)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "COND"))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|TIME))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|FREQ))

#PE#

rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "pe.LRN.nDT.P3.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

eZa = ezANOVA (pat, dv = .(AVG), wid = .(SUB), within= .(CUE,CHAN), detailed=T)
print(eZa)

#model.pat <- lme4::lmer(AVG ~ (CUE*CHAN) + (1|SUB), data =pat)
#a         <-Anova(model.pat,type=2)
#print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "CHAN"))

# GFP

rm(list=ls())
ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/"
ext2  = "nDT.GFP.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)
#model.pat <- lme4::lmer(GFP ~ (COND+COMP)^2 + (1|SUB), data =pat)
#a         <-Anova(model.pat,type=2)
#print(a)

eZa = ezANOVA (pat, dv = .(GFP), wid = .(SUB), within= .(COND,COMP), detailed=T)
print(eZa)