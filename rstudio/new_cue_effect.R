library(ez)
library(car)
rm(list=ls())
ext1  = "~/Dropbox/Fieldtripping/txt/";
ext2  = "BigCovariance.CnD.WithEvoked.NeutralSeparate.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

pat   = pat[pat$TIME != "1000ms",]

model.pat <- lme4::lmer(POW ~ (COND+HEMI+MODALITY+FREQ+TIME)^5 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2)
print(a)

subpat = pat[pat$HEMI=="R",]
model.subpat <- lme4::lmer(POW ~ (COND+MODALITY+FREQ)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|MODALITY))

subpat = pat[pat$HEMI=="L" ,]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ+MODALITY)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|MODALITY))

subpat = pat[pat$HEMI=="L" & pat$MODALITY  =="occ",]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ)^2 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|FREQ))