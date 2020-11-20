library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);
library(lme4);library(lsmeans);library(ggplot2);library(RColorBrewer)
library(ggsci);library(sjstats)
library(pwr)

rm(list=ls())
pd <- position_dodge(0.2) # move them .05 to the left and right

ext1                  <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2                  <- "ageingrev_alphatimecourse_adapted0Hz_CUECAT.txt" 
pat                   <-  read.table(paste0(ext1,ext2),header=T)

sub_old               <- subset(pat,  GROUP == "old", drop = TRUE)

sub_old_v             <- subset(sub_old,  MOD == "vis", drop = TRUE)
sub_old_v_inf         <- subset(sub_old_v,  CUE_CAT == "informative", POW,drop = TRUE)
sub_old_v_unf         <- subset(sub_old_v,  CUE_CAT == "uninformative", POW,drop = TRUE)

res_old_v             <- t.test(sub_old_v_inf, sub_old_v_unf, paired = TRUE)

sub_old_a             <- subset(sub_old,  MOD == "aud", drop = TRUE)
sub_old_a_inf         <- subset(sub_old_a,  CUE_CAT == "informative", POW,drop = TRUE)
sub_old_a_unf         <- subset(sub_old_a,  CUE_CAT == "uninformative", POW,drop = TRUE)

res_old_a             <- t.test(sub_old_a_inf, sub_old_a_unf, paired = TRUE)

sub_old_m             <- subset(sub_old,  MOD == "mot", drop = TRUE)
sub_old_m_inf         <- subset(sub_old_m,  CUE_CAT == "informative", POW,drop = TRUE)
sub_old_m_unf         <- subset(sub_old_m,  CUE_CAT == "uninformative", POW,drop = TRUE)

res_old_m             <- t.test(sub_old_m_inf, sub_old_m_unf, paired = TRUE)

sub_yng               <- subset(pat,  GROUP == "young", drop = TRUE)

sub_yng_v             <- subset(sub_yng,  MOD == "vis", drop = TRUE)
sub_yng_v_inf         <- subset(sub_yng_v,  CUE_CAT == "informative", POW,drop = TRUE)
sub_yng_v_unf         <- subset(sub_yng_v,  CUE_CAT == "uninformative", POW,drop = TRUE)

res_yng_v             <- t.test(sub_yng_v_inf, sub_yng_v_unf, paired = TRUE)

sub_yng_a             <- subset(sub_yng,  MOD == "aud", drop = TRUE)
sub_yng_a_inf         <- subset(sub_yng_a,  CUE_CAT == "informative", POW,drop = TRUE)
sub_yng_a_unf         <- subset(sub_yng_a,  CUE_CAT == "uninformative", POW,drop = TRUE)

res_yng_a             <- t.test(sub_yng_a_inf, sub_yng_a_unf, paired = TRUE)

sub_yng_m             <- subset(sub_yng,  MOD == "mot", drop = TRUE)
sub_yng_m_inf         <- subset(sub_yng_m,  CUE_CAT == "informative", POW,drop = TRUE)
sub_yng_m_unf         <- subset(sub_yng_m,  CUE_CAT == "uninformative", POW,drop = TRUE)

res_yng_m             <- t.test(sub_yng_m_inf, sub_yng_m_unf, paired = TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CAT","MOD","GROUP"))

ggplot2::ggplot(tgc, aes(x=MOD, y=POW, fill=CUE_CAT)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.5,0.5)+
  theme_minimal()+
  facet_wrap(~GROUP)+
  scale_fill_grey(start = 0.8, end = 0.2)
