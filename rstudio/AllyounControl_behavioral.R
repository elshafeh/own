library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "allyoungcontrol_behavioral_performance.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(MedianRT   ~ (CUE_CAT+DIS)^2 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model_ez <- ezANOVA(pat,dv=.(MedianRT),wid = .(SUB),within = .(CUE_CAT,DIS),detailed=T)
print(model_ez)


lsmeans::cld(lsmeans::lsmeans(model.pat,   "DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,   "CUE_CAT"),details= TRUE)

model.pat      <- lme4::lmer(PerIncorrect     ~ (CUE_CAT+DIS)^2 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model_ez <- ezANOVA(pat,dv=.(PerIncorrect),wid = .(SUB),within = .(CUE_CAT,DIS),detailed=T)
print(model_ez)

lsmeans::cld(lsmeans::lsmeans(model.pat,   "DIS"),details= TRUE)

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE_CAT","DIS"))

pd <- position_dodge(0.1) # move them .05 to the left and right

p1 <- ggplot(tgc, aes(x=DIS, y=MedianRT, colour=CUE_CAT, group=CUE_CAT)) + 
  geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(450,600)+theme_classic()

tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("CUE_CAT","DIS"))

p2 <- ggplot(tgc, aes(x=DIS, y=PerIncorrect, colour=CUE_CAT, group=CUE_CAT)) + 
  geom_errorbar(aes(ymin=PerIncorrect-se, ymax=PerIncorrect+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(0,8)+theme_classic()

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("", ""))

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


model.pat      <- lme4::lmer(PerFA   ~ (CUE_CAT+DIS)^2 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,   "DIS"),details= TRUE)

tgc <- summarySE(pat, measurevar="PerFA", groupvars=c("DIS"))

ggplot(tgc, aes(x=DIS, y=PerFA)) + 
  geom_errorbar(aes(ymin=PerFA-se, ymax=PerFA+se), colour="black", width=.1) +
  geom_line() +
  geom_point(size=3)+ylim(0,0.15)+theme_classic()

tgc <- summarySE(pat, measurevar="PerCorrect")
tgc <- summarySE(pat, measurevar="PerIncorrect")
tgc <- summarySE(pat, measurevar="PerFA")
tgc <- summarySE(pat, measurevar="PerMiss")