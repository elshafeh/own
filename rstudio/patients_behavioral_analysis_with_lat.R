library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

# Suppose factor1 has i levels and factor2 has j levels and you have n subjects tested
# df for factor1 = i-1
# df for factor2 = j-1
# df for interaction factor1 x factor2 = (i-1)*(j-1)
# df for error(factor1) = (i-1)*(n-1)
# df for error(factor2) = (j-1)*(n-1)
# df for error(factor1xfactor2) = (i-1)*(j-1)*(n-1)
# F for factor1 = MeanSquare of factor1 divided by MeanSquare of error of factor1
# F for factor2 = MeanSquare of factor2 divided by MeanSquare of error of factor2

# n2 = nom / [nom+dom]

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "patient_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$GROUP == 'patient',]

model.pat      <- lme4::lmer(MedianRT ~ (LAT_LESION+TAR_SIDE+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  "DIS"),details= TRUE)

model.pat      <- lme4::lmer(PerIncorrect ~ (LAT_LESION+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

# no difference between groups

model.pat      <- lme4::lmer(PerFA ~ (LAT_LESION+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model.pat      <- lme4::lmer(PerMiss ~ (LAT_LESION+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

# separate tests

list_group <- as.character(unique(pat$LAT_LESION))
spec_test  <- data.frame(SUB=character(), LAT_LESION=character())

for (gr in 1:length(list_group)){
  
  list_suj <- pat[pat$LAT_LESION==list_group[gr],]
  list_suj <- as.character(unique(list_suj$SUB))
  
  for (sb in 1:length(list_suj)){
    
    suj  = list_suj[sb]
    
    vcue = mean(pat[pat$LAT_LESION==list_group[gr] & pat$SUB==suj & pat$DIS=='D0' & pat$CUE_CAT=='informative',6])
    ncue = mean(pat[pat$LAT_LESION==list_group[gr] & pat$SUB==suj & pat$DIS=='D0' & pat$CUE_CAT=='uninformative',6])
    
    
    D0= mean(pat[pat$LAT_LESION==list_group[gr] & pat$SUB==suj & pat$DIS=='D0',6])
    D1= mean(pat[pat$LAT_LESION==list_group[gr] & pat$SUB==suj & pat$DIS=='D1',6])
    D2= mean(pat[pat$LAT_LESION==list_group[gr] & pat$SUB==suj & pat$DIS=='D2',6])
    
    bloc <- cbind(suj,list_group[gr],ncue-vcue,D0-D1,D2-D1,D2-D0)
    spec_test<-rbind(spec_test,bloc)
    
  }
}

names(spec_test) <- c("SUB","LAT_LESION","vcueMINUSncue","D0MINUSD1","D1MINUSD2","D0MINUSD2")
spec_test$vcueMINUSncue <- as.numeric(levels(spec_test$vcueMINUSncue))[spec_test$vcueMINUSncue]
spec_test$D0MINUSD1 <- as.numeric(levels(spec_test$D0MINUSD1))[spec_test$D0MINUSD1]
spec_test$D1MINUSD2 <- as.numeric(levels(spec_test$D1MINUSD2))[spec_test$D1MINUSD2]
spec_test$D0MINUSD2 <- as.numeric(levels(spec_test$D0MINUSD2))[spec_test$D0MINUSD2]

spec_test$SUB = factor(spec_test$SUB)
spec_test$LAT_LESION = factor(spec_test$LAT_LESION)

res <- t.test(spec_test[spec_test$LAT_LESION=='L_lesion',"D1MINUSD2"], spec_test[spec_test$LAT_LESION=='R_lesion',"D1MINUSD2"])
res

res <- t.test(spec_test[spec_test$LAT_LESION=='L_lesion',"D0MINUSD1"], spec_test[spec_test$LAT_LESION=='R_lesion',"D0MINUSD1"])
res

res <- t.test(spec_test[spec_test$LAT_LESION=='L_lesion',"D0MINUSD2"], spec_test[spec_test$LAT_LESION=='R_lesion',"D0MINUSD2"])
res

res <- t.test(spec_test[spec_test$LAT_LESION=='L_lesion',"vcueMINUSncue"], spec_test[spec_test$LAT_LESION=='R_lesion',"vcueMINUSncue"])
res