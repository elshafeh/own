library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())


ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "yc_all_BroadandNeigh_MinEvoked_iaf_p600p1000_1Cue_two_occ.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

new_pat = pat[pat$CUE == "5Neig",]; new_pat$CHAN = factor(new_pat$CHAN)

model.pat      <- lme4::lmer(IAF ~ (MOD+HEMI)^2 +  (1|SUB), data =new_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans(model.pat,  "MOD" , details= TRUE)

new_pat = pat[pat$CUE == "broad",]; new_pat$CHAN = factor(new_pat$CHAN)

model.pat      <- lme4::lmer(IAF ~ (MOD+HEMI)^2 +  (1|SUB), data =new_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans(model.pat,  "MOD" , details= TRUE)

aud_5_iaf = median(pat[pat$MOD == "Auditory" & pat$CUE == "5Neig","IAF"])
occ_5_iaf = median(pat[pat$MOD == "Occipital" & pat$CUE == "5Neig","IAF"])

aud_b_iaf = median(pat[pat$MOD == "Auditory" & pat$CUE == "broad","IAF"])
occ_b_iaf = median(pat[pat$MOD == "Occipital" & pat$CUE == "broad","IAF"])
