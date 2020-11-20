library(ez)
library(car)

#pat = read.table("/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.behav/stat/prep_R/PrepAtt2_new_medianRT_LRsep.txt",header=T)
#pat = read.table("/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.behav/stat/prep_R/PrepAtt2_new_PerCorr_LRsep.txt",header=T)

pat = read.table("/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.behav/stat/prep_R/PrepAtt2_new_miss_LRsep.txt",header=T)
pat = pat[pat$DIS == 'D0' ,]

model.pat <- lme4::lmer(miss ~ CUE + (1|SUB), data =pat)
a         <- Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "DIS"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "BLOC"))

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE|DIS))