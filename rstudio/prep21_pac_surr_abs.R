library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
cbPalette <- c( "#009E73","#E69F00","#999999")

ext1        <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "prep21_PhaseAmplitudeCoupling_p600p1000_prep21.maxAVMsepVoxels.sepFreq_low.9t13.high5step.50t110_optimisedPACeEvoked.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

pat$POW     <- pat$POW/1e+9
pat         <- pat[pat$NORM_TYPE == "surrnorm" & pat$BSL_TYPE ==  "abs",]

model.pat   <- lme4::lmer(POW ~ (CUE+HEMI+LOW_FREQ+METHOD)^4 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))

print(model_anova)

sub_pat     <- pat[pat$HEMI == "L_Hemi",]

model.pat   <- lme4::lmer(POW ~ (CUE+LOW_FREQ+METHOD)^3 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))

print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat     <- pat[pat$HEMI == "R_Hemi",]

model.pat   <- lme4::lmer(POW ~ (CUE+LOW_FREQ+METHOD)^3 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))

print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat     <- pat[pat$HEMI == "R_Hemi" & pat$LOW_FREQ=="09Hz",]

model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))

print(sep_anova)

sub_pat     <- pat[pat$HEMI == "R_Hemi" & pat$LOW_FREQ=="13Hz",]

model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))

print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat     <- pat[pat$HEMI == "R_Hemi",]

model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))

print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)


sub_pat     <- pat[pat$HEMI == "L_Hemi",]

model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))

print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)
