library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())
cbPalette <- c( "#009E73","#E69F00","#999999")

ext1        <- "//Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "prep21_allTDBU_slct_VirtualConnectivity_MinEvoked_2Freq_sep_time.txt"
pat         <-  read.table(paste0(ext1,ext2),header=T)

pat         <-  pat[pat$METHOD != "coh" ,]
pat$METHOD  <- factor(pat$METHOD)
 
pat         <- pat[pat$TARGET != "LHDorsAttnPost5" & pat$TARGET != "LHSalVentAttnMed1" & pat$TARGET != "LHSalVentAttnMed2",]
pat$TARGET  <- factor(pat$TARGET)

model.pat_plv   <- lme4::lmer(POW ~ (CUE_CONC+FREQ+TARGET)^3 + (1|SUB), data =pat)
model_anova_plv <-Anova(model.pat_plv,type=2,test.statistic=c("F"))
print(model_anova_plv)

lsmeans::cld(lsmeans::lsmeans(model.pat_plv,  pairwise~CUE_CONC|TARGET),details= TRUE)

sub_pat             <-  pat[pat$FREQ == "09Hz",]

sub_model.pat_plv   <- lme4::lmer(POW ~ (CUE_CONC+TARGET)^2 + (1|SUB), data =sub_pat)
sub_model_anova_plv <-Anova(sub_model.pat_plv,type=2,test.statistic=c("F"))
print(sub_model_anova_plv)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat_plv,  pairwise~CUE_CONC|TARGET),details= TRUE)

tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_CONC","TARGET"))
ggplot2::ggplot(tgc, aes(x=TARGET, y=POW, fill=CUE_CONC)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.5,0.5)+scale_fill_manual(values=cbPalette)


sub_pat             <-  pat[pat$FREQ == "13Hz",]

sub_model.pat_plv   <- lme4::lmer(POW ~ (CUE_CONC+TARGET)^2 + (1|SUB), data =sub_pat)
sub_model_anova_plv <-Anova(sub_model.pat_plv,type=2,test.statistic=c("F"))
print(sub_model_anova_plv)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat_plv,  pairwise~CUE_CONC|TARGET),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CONC","TARGET"))
pd <- position_dodge(0.1) # move them .05 to the left and right
ggplot2::ggplot(tgc, aes(x=TARGET, y=POW, fill=CUE_CONC)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.5,0.5)+scale_fill_manual(values=cbPalette)
