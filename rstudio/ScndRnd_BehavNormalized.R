library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())
ext1                <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2                <- "ageing_normalizedRT.txt" 
pat                 <-  read.table(paste0(ext1,ext2),header=T)

model1.pat          <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat)
model2.pat          <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^3 + (CUE_CAT|SUB), data =pat)
model3.pat          <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^3 + (DIS|SUB), data =pat)
model4.pat          <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^3 + (CUE_CAT+DIS|SUB), data =pat)

model_anova1        <- Anova(model1.pat,type=2,test.statistic=c("F"))
model_anova2        <- Anova(model2.pat,type=2,test.statistic=c("F"))
model_anova3        <- Anova(model3.pat,type=2,test.statistic=c("F"))
model_anova4        <- Anova(model4.pat,type=2,test.statistic=c("F"))

compare1            <- anova(model1.pat,model2.pat,model3.pat,model4.pat)
print(compare1)

print(model_anova1)
print(model_anova2)
print(model_anova3)
print(model_anova4)

lsmeans(model3.pat,  pairwise~GROUP|DIS,details= TRUE)

pd <- position_dodge(0.1) # move them .05 to the left and right

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE_CAT","GROUP","DIS"))

ggplot(tgc, aes(x=DIS, y=MedianRT,colour=CUE_CAT,group=CUE_CAT)) + 
  geom_point(position=pd, size=3)+
  geom_line() +
  geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), width=.1, position=pd) +
  ylim(0.9,1.15)+
  theme_linedraw()+
  facet_wrap(~GROUP)