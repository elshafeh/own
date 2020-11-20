library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "PrepAtt2_lat_index_age_contrast_separateROIs_two_Freq_Sep_Time.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$TIME != "1000ms",] ; pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE+FREQ_CAT)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat        <-  pat[pat$HEMI == "L_Hemi",]
sub_model.pat   <- lme4::lmer(POW ~ (FREQ_CAT+CUE_ORIG)^2 + (1|SUB), data =sub_pat)
sub_model_anova <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_ORIG|FREQ_CAT),details= TRUE)
# 