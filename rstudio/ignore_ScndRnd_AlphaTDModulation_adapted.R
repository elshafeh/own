library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);
library(lme4);library(lsmeans);library(ggplot2);library(RColorBrewer)
library(ggsci)

rm(list=ls())
pd <- position_dodge(0.2) # move them .05 to the left and right

ext1                <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2                <- "ageingrev_alphatimecourse_adapted.txt" 
pat                 <-  read.table(paste0(ext1,ext2),header=T)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_POSITION","MOD","GROUP"))

ggplot2::ggplot(tgc, aes(x=MOD, y=POW, fill=CUE_POSITION)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.5,0.5)+
  theme_minimal()+
  facet_wrap(~GROUP)+
  scale_fill_grey(start = 0.8, end = 0.2)

model1.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (1|SUB), data =pat)
model2.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (CUE_POSITION|SUB), data =pat)
model3.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (HEMI|SUB), data =pat)
model4.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (MOD|SUB), data =pat)

model5.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (CUE_POSITION+HEMI|SUB), data =pat)
model6.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (CUE_POSITION+MOD|SUB), data =pat)
model8.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^4 + (CUE_POSITION+HEMI+MOD|SUB), data =pat)

compare1            <- anova(model1.pat,model2.pat,model3.pat,model4.pat,
                             model5.pat,model6.pat,model7.pat,model8.pat)
print(compare1)

compare2            <- anova(model4.pat,model7.pat)
print(compare2)

model7.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI+MOD)^3 + (HEMI+MOD|SUB), data =pat)
model_anova7        <- Anova(model7.pat,type=2,test.statistic=c("F"))
print(model_anova7)

sub_pat             <- pat[pat$GROUP == "Old",]
sub_pat$GROUP       <- factor(sub_pat$GROUP)
sub_model1.pat      <- lme4::lmer(POW ~ (CUE_POSITION+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova1    <- Anova(sub_model1.pat,type=2,test.statistic=c("F"))
print(sub_model_anova1)

sub_pat             <- pat[pat$GROUP == "Young",]
sub_pat$GROUP       <- factor(sub_pat$GROUP)
sub_model2.pat      <- lme4::lmer(POW ~ (CUE_POSITION+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova2    <- Anova(sub_model2.pat,type=2,test.statistic=c("F"))
print(sub_model_anova2)

sub_pat                     <- pat[pat$CUE_POSITION == "contralateral",]
sub_pat$CUE_POSITION        <- factor(sub_pat$CUE_POSITION)
sub_model3.pat              <- lme4::lmer(POW ~ (GROUP+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova3            <- Anova(sub_model3.pat,type=2,test.statistic=c("F"))

sub_pat                     <- pat[pat$CUE_POSITION == "ipsilateral",]
sub_pat$CUE_POSITION        <- factor(sub_pat$CUE_POSITION)
sub_model4.pat              <- lme4::lmer(POW ~ (GROUP+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova4            <- Anova(sub_model4.pat,type=2,test.statistic=c("F"))

sub_pat                     <- pat[pat$CUE_POSITION == "uninformative",]
sub_pat$CUE_POSITION        <- factor(sub_pat$CUE_POSITION)
sub_model5.pat              <- lme4::lmer(POW ~ (GROUP+MOD)^2 + (1|SUB), data =sub_pat)
sub_model_anova5            <- Anova(sub_model5.pat,type=2,test.statistic=c("F"))

print(sub_model_anova3)
print(sub_model_anova4)
print(sub_model_anova5)

lsmeans(sub_model3.pat,  pairwise~GROUP|MOD , details= TRUE)
lsmeans(sub_model4.pat,  pairwise~GROUP|MOD , details= TRUE)
lsmeans(sub_model5.pat,  pairwise~GROUP|MOD , details= TRUE)