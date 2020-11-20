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

pat                 <- pat[pat$MOD == "aud",]
pat$MOD             <- factor(pat$MOD)
pat$CHAN            <- factor(pat$CHAN)

model1.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI)^3 + (1|SUB), data =pat)
model2.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI)^3 + (CUE_POSITION|SUB), data =pat)
model3.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI)^3 + (HEMI|SUB), data =pat)
model4.pat          <- lme4::lmer(POW ~ (GROUP+CUE_POSITION+HEMI)^3 + (CUE_POSITION+HEMI|SUB), data =pat)

compare1            <- anova(model1.pat,model2.pat,model3.pat,model4.pat)
print(compare1)

compare2            <- anova(model3.pat,model4.pat)
print(compare2)

# winnder is model4! 

model_anova         <- Anova(model4.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model4.pat,  "CUE_POSITION"),details= TRUE)


# sub_pat             <- pat[pat$GROUP == "Old",]
# sub_pat$GROUP       <- factor(sub_pat$GROUP)
# 
# sub_model1.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (1|SUB), data =sub_pat)
# sub_model2.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (CUE_POSITION|SUB), data =sub_pat)
# sub_model3.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (HEMI|SUB), data =sub_pat)
# 
# compare1            <- anova(sub_model1.pat,sub_model2.pat,sub_model3.pat)
# print(compare1)
# 
# compare1            <- anova(sub_model2.pat,sub_model3.pat)
# print(compare1)
# 
# # winner is 3
# sub_model_anova1    <- Anova(sub_model3.pat,type=2,test.statistic=c("F"))
# print(sub_model_anova1)
# 
# sub_pat             <- pat[pat$GROUP == "Young",]
# sub_pat$GROUP       <- factor(sub_pat$GROUP)
# 
# sub_model1.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (1|SUB), data =sub_pat)
# sub_model2.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (CUE_POSITION|SUB), data =sub_pat)
# sub_model3.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (HEMI|SUB), data =sub_pat)
# 
# compare1            <- anova(sub_model1.pat,sub_model2.pat,sub_model3.pat)
# print(compare1)
# 
# # winner is 3
# compare1            <- anova(sub_model2.pat,sub_model3.pat)
# print(compare1)
# 
# sub_model_anova1    <- Anova(sub_model3.pat,type=2,test.statistic=c("F"))
# print(sub_model_anova1)