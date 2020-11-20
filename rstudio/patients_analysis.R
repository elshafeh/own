library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "patients_behavioral_performance.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(MedianRT ~ (GROUP+CUE+DIS)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  "DIS"),details= TRUE)

model.pat      <- lme4::lmer(PerCorrect ~ (GROUP+CUE+DIS)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  "DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise ~ CUE|GROUP),details= TRUE)

model.pat      <- lme4::lmer(PerFA ~ (GROUP+CUE+DIS)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model.pat      <- lme4::lmer(PerMiss ~ (GROUP+CUE+DIS)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  "CUE"),details= TRUE)


tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE","DIS","GROUP"))

interaction.ABC.plot(MedianRT, x.factor=DIS,
                     groups.factor=CUE, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y="Median Reaction Tme"),
                                                 ggtitle(""),
                                                 ylim(500,900),
                                                 geom_errorbar(data=tgc,aes(ymax=MedianRT+se, ymin=MedianRT-se),width=0.2)))

tgc <- summarySE(pat, measurevar="PerCorrect", groupvars=c("CUE","DIS","GROUP"))

interaction.ABC.plot(PerCorrect, x.factor=DIS,
                     groups.factor=CUE, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y="% Correct"),
                                                 ggtitle(""),
                                                 ylim(85,100),
                                                 geom_errorbar(data=tgc,aes(ymax=PerCorrect+se, ymin=PerCorrect-se),width=0.2)))

tgc <- summarySE(pat, measurevar="PerMiss", groupvars=c("CUE","DIS","GROUP"))

interaction.ABC.plot(PerMiss, x.factor=DIS,
                     groups.factor=CUE, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y="% Miss"),
                                                 ggtitle(""),
                                                 ylim(0,3),
                                                 geom_errorbar(data=tgc,aes(ymax=PerMiss+se, ymin=PerMiss-se),width=0.2)))

tgc <- summarySE(pat, measurevar="PerFA", groupvars=c("CUE","DIS","GROUP"))

interaction.ABC.plot(PerFA, x.factor=DIS,
                     groups.factor=CUE, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y="% FA"),
                                                 ggtitle(""),
                                                 ylim(0,3),
                                                 geom_errorbar(data=tgc,aes(ymax=PerFA+se, ymin=PerFA-se),width=0.2)))

list_group <- as.character(unique(pat$GROUP))
spec_test  <- data.frame(SUB=character(), GROUP=character())

for (gr in 1:length(list_group)){
  
  list_suj <- pat[pat$GROUP==list_group[gr],]
  list_suj <- as.character(unique(list_suj$SUB))
  
  for (sb in 1:length(list_suj)){
    
    suj  = list_suj[sb]
    
    vcue = mean(pat[pat$GROUP==list_group[gr] & pat$SUB==suj & pat$DIS=='D0' & pat$CUE_CAT=='informative',6])
    ncue = mean(pat[pat$GROUP==list_group[gr] & pat$SUB==suj & pat$DIS=='D0' & pat$CUE_CAT=='uninformative',6])
    
    
    D0= mean(pat[pat$GROUP==list_group[gr] & pat$SUB==suj & pat$DIS=='D0',6])
    D1= mean(pat[pat$GROUP==list_group[gr] & pat$SUB==suj & pat$DIS=='D1',6])
    D2= mean(pat[pat$GROUP==list_group[gr] & pat$SUB==suj & pat$DIS=='D2',6])
    
    bloc <- cbind(suj,list_group[gr],ncue-vcue,D0-D1,D2-D1,D2-D0)
    spec_test<-rbind(spec_test,bloc)
    
  }
}

names(spec_test) <- c("SUB","GROUP","vcueMINUSncue","D0MINUSD1","D1MINUSD2","D0MINUSD2")
spec_test$vcueMINUSncue <- as.numeric(levels(spec_test$vcueMINUSncue))[spec_test$vcueMINUSncue]
spec_test$D0MINUSD1 <- as.numeric(levels(spec_test$D0MINUSD1))[spec_test$D0MINUSD1]
spec_test$D1MINUSD2 <- as.numeric(levels(spec_test$D1MINUSD2))[spec_test$D1MINUSD2]
spec_test$D0MINUSD2 <- as.numeric(levels(spec_test$D0MINUSD2))[spec_test$D0MINUSD2]

spec_test$SUB = factor(spec_test$SUB)
spec_test$GROUP = factor(spec_test$GROUP)

res <- t.test(spec_test[spec_test$GROUP=='patient',"D1MINUSD2"], spec_test[spec_test$GROUP=='control',"D1MINUSD2"])
res

res <- t.test(spec_test[spec_test$GROUP=='patient',"D0MINUSD1"], spec_test[spec_test$GROUP=='control',"D0MINUSD1"])
res

res <- t.test(spec_test[spec_test$GROUP=='patient',"D0MINUSD2"], spec_test[spec_test$GROUP=='control',"D0MINUSD2"])
res

res <- t.test(spec_test[spec_test$GROUP=='patient',"vcueMINUSncue"], spec_test[spec_test$GROUP=='control',"vcueMINUSncue"])
res