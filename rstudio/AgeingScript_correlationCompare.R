library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls()) ; pd <- position_dodge(0.05) # move them .05 to the left and right

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "ageing_CnD_virtual_singleTrialCorrelation.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$FREQ == "09Hz" | pat$FREQ =="13Hz",]
pat$FREQ       <- factor(pat$FREQ)

model.pat      <- lme4::lmer(ZCORR ~ (GROUP+FREQ+MOD+HEMI)^4 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat             <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ        <- factor(sub_pat$FREQ)
sub_model.pat       <- lme4::lmer(ZCORR ~ (GROUP+MOD+HEMI)^3 + (1|SUB), data =sub_pat)
sub_model_anova     <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

sub_pat             <- pat[pat$FREQ == "09Hz" & pat$HEMI == "L_Hemi",]
sub_pat$FREQ        <- factor(sub_pat$FREQ)
sub_pat$HEMI        <- factor(sub_pat$HEMI)
sub_model.pat       <- lme4::lmer(ZCORR ~ (GROUP+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova     <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  pairwise~GROUP|MOD , details= TRUE)

sub_pat             <- pat[pat$FREQ == "09Hz" & pat$HEMI == "R_Hemi",]
sub_pat$FREQ        <- factor(sub_pat$FREQ)
sub_pat$HEMI        <- factor(sub_pat$HEMI)
sub_model.pat       <- lme4::lmer(ZCORR ~ (GROUP+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova     <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  pairwise~GROUP|MOD , details= TRUE)

sub_pat             <- pat[pat$FREQ == "13Hz",]
sub_pat$FREQ        <- factor(sub_pat$FREQ)
sub_model.pat       <- lme4::lmer(ZCORR ~ (GROUP+MOD+HEMI)^3 + (1|SUB), data =sub_pat)
sub_model_anova     <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  pairwise~GROUP|MOD , details= TRUE)


