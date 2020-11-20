library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(optimx)
library(simr)

rm(list=ls())

ext1           <- "~/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2           <- "ageingpaper_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

## percentages 

model1.pat          <- lme4::lmer(PerIncorrect ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat)
model_anova1     <- Anova(model1.pat,type=2,test.statistic=c("F"))
print(model_anova1)

lsmeans(model1.pat,  "DIS",details= TRUE, adjust = "mvt")

## reaction times

model3.pat          <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^3 + (DIS|SUB), data =pat,REML = TRUE,
                                  control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb')))

model_anova3     <- Anova(model3.pat,type=2,test.statistic=c("F"))

print(model_anova3)

lsmeans(model3.pat,  "CUE_CAT",details= TRUE)
lsmeans(model3.pat,  "DIS",details= TRUE)

lsmeans(model3.pat,   pairwise~GROUP|DIS,details= TRUE)

pd <- position_dodge(0.1) # move them .05 to the left and right

tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("CUE_CAT","GROUP","DIS"))

ggplot(tgc, aes(x=DIS, y=PerIncorrect,colour=CUE_CAT,group=CUE_CAT)) + 
  geom_point(position=pd, size=3)+
  geom_line() +
  geom_errorbar(aes(ymin=PerIncorrect-se, ymax=PerIncorrect+se), width=.1, position=pd) +
  ylim(0,10)+
  theme_linedraw()+
  facet_wrap(~GROUP)
