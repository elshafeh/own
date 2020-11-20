library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);
library(lme4);library(lsmeans);library(ggplot2);library(RColorBrewer)
library(ggsci);library(sjstats)
library(pwr);library(emmeans);library(optimx)
library("multcomp")

rm(list=ls())
pd <- position_dodge(0.2) # move them .05 to the left and right

# Suppose factor1 has i levels and factor2 has j levels and you have n subjects tested
# df for factor1 = i-1
# df for factor2 = j-1
# df for interaction factor1 x factor2 = (i-1)*(j-1)
# df for error(factor1) = (i-1)*(n-1)
# df for error(factor2) = (j-1)*(n-1)
# df for error(factor1xfactor2) = (i-1)*(j-1)*(n-1)

ext1                <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2                <- "ageingrev_alphatimecourse_adapted0Hz.txt" 
pat                 <-  read.table(paste0(ext1,ext2),header=T)

# winnder is model 7
model7.pat          <- lme4::lmer(POW ~ (GROUP+CUE_CAT+HEMI+MOD)^3 + (HEMI+MOD|SUB), data =pat,REML = TRUE,
                                  control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb')))

# compute anova
model_anova         <- Anova(model7.pat,type=2,test.statistic=c("F"))
# print anova
print(model_anova)

eta_sq(model7.pat, partial = FALSE, ci.lvl = NULL, n = 1000, method = c("dist", "quantile"))
anova_stats(model7.pat, digits = 3)

#pour la double interaction #1:
res1  <- lsmeans(model7.pat,  pairwise ~ GROUP | MOD)
print(res1)

#pour la double interaction #2:
res2  <- lsmeans(model7.pat,  pairwise ~ HEMI | MOD)
print(res2)


#pour la triple interaction:
res3  <-lsmeans(model7.pat,  pairwise ~ (CUE_CAT) | MOD*GROUP , details= TRUE)
print(res3)


PH.emmeans <- emmeans(model7.pat, "CUE_CAT", by = c("MOD", "GROUP"))
summary(as.glht(update(pairs(PH.emmeans), by = NULL)), test = adjusted("free"))
