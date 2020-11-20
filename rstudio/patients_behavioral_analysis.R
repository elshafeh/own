library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(ggpubr)

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

model.pat      <- lme4::lmer(PerIncorrect ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model_ez <- ezANOVA(pat,dv=.(PerIncorrect),wid = .(SUB),between = GROUP,within = .(CUE_CAT,DIS),detailed=T)
print(model_ez)

model.pat      <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model_ez <- ezANOVA(pat,dv=.(MedianRT),wid = .(SUB),between = GROUP,within = .(CUE_CAT,DIS),detailed=T)
print(model_ez)

lsmeans::cld(lsmeans::lsmeans(model.pat,  "DIS"),details= TRUE)

# no difference between groups

model.pat      <- lme4::lmer(PerFA ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model.pat      <- lme4::lmer(PerMiss ~ (GROUP+CUE_CAT+DIS)^3 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

# separate tests

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
    
    z = 0
    
    bloc <- cbind(suj,list_group[gr],ncue-vcue,D0-D1,D2-D1,D2-D0,z)
    spec_test<-rbind(spec_test,bloc)
    
  }
}

names(spec_test) <- c("SUB","GROUP","vcueMINUSncue","D0MINUSD1","D1MINUSD2","D0MINUSD2","zero")
spec_test$vcueMINUSncue <- as.numeric(levels(spec_test$vcueMINUSncue))[spec_test$vcueMINUSncue]
spec_test$D0MINUSD1 <- as.numeric(levels(spec_test$D0MINUSD1))[spec_test$D0MINUSD1]
spec_test$D1MINUSD2 <- as.numeric(levels(spec_test$D1MINUSD2))[spec_test$D1MINUSD2]
spec_test$D0MINUSD2 <- as.numeric(levels(spec_test$D0MINUSD2))[spec_test$D0MINUSD2]
spec_test$zero <- as.numeric(levels(spec_test$zero))[spec_test$zero]

spec_test$SUB = factor(spec_test$SUB)
spec_test$GROUP = factor(spec_test$GROUP)

x = spec_test[spec_test$GROUP == "patient","vcueMINUSncue"]
wilcox.test(x, mu = 0, alternative = "two.sided")

x = spec_test[spec_test$GROUP == "patient","D1MINUSD2"]
wilcox.test(x, mu = 0, alternative = "two.sided")

x = spec_test[spec_test$GROUP == "patient","D0MINUSD1"]
wilcox.test(x, mu = 0, alternative = "two.sided")


x = spec_test[spec_test$GROUP == "control","vcueMINUSncue"]
wilcox.test(x, mu = 0, alternative = "two.sided")

x = spec_test[spec_test$GROUP == "control","D1MINUSD2"]
wilcox.test(x, mu = 0, alternative = "two.sided")

x = spec_test[spec_test$GROUP == "control","D0MINUSD1"]
wilcox.test(x, mu = 0, alternative = "two.sided")



kruskal.test(vcueMINUSncue~GROUP,data=spec_test)
kruskal.test(D0MINUSD2~GROUP,data=spec_test)
kruskal.test(D0MINUSD1~GROUP,data=spec_test)
kruskal.test(D1MINUSD2~GROUP,data=spec_test)

pd <- position_dodge(0.1) # move them .05 to the left and right

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE_CAT","GROUP","DIS"))

interaction.ABC.plot(MedianRT, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(theme_bw(),geom_point(position=pd, size=3, shape=21,fill="white"),
                                                 geom_line(position=pd,size = 0.2),
                                                 labs(x="Dis Delay",y="Reaction Time"),
                                                 ggtitle(""),
                                                 ylim(400,900),
                                                 geom_errorbar(data=tgc,position=pd,aes(ymax=MedianRT+se, ymin=MedianRT-se),width=0.2)))+theme_classic()


tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("DIS"))

p1 <- ggplot(tgc, aes(x=DIS, y=PerIncorrect, colour=DIS, group=DIS)) + 
  geom_errorbar(aes(ymin=PerIncorrect-se, ymax=PerIncorrect+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3, shape=21, fill="white") +ylim(0, 15)+theme_classic()# 21 is filled circle


tgc <- summarySE(spec_test, measurevar="D1MINUSD2", groupvars=c("GROUP"))

p2 <-ggplot(spec_test, aes(x=GROUP, y=D1MINUSD2, fill=GROUP)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=4, color="red", fill="red") +
  theme(legend.position="none") + ylim(0,300)+theme_classic()

tgc <- summarySE(spec_test, measurevar="vcueMINUSncue", groupvars=c("GROUP"))

p3 <- ggplot(spec_test, aes(x=GROUP, y=vcueMINUSncue, fill=GROUP)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=4, color="red", fill="red") +
  theme(legend.position="none") + ylim(-100,100)+theme_classic()

ggarrange(p1, p2,p3,ncol = 2, nrow = 2)

tgc <- summarySE(spec_test, measurevar="D0MINUSD1", groupvars=c("GROUP"))

ggplot(spec_test, aes(x=GROUP, y=D0MINUSD1, fill=GROUP)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=4, color="red", fill="red") +
  theme(legend.position="none") + ylim(-150,150)+theme_classic()

pat            <- pat[pat$DIS == "D0",]

model.pat      <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT)^2 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_CAT|GROUP),details= TRUE)


tgc <- summarySE(pat, measurevar="PerIncorrect", groupvars=c("DIS","GROUP"))

ggplot(tgc, aes(x=DIS, y=PerIncorrect, colour=GROUP, group=GROUP)) + 
  geom_errorbar(aes(ymin=PerIncorrect-se, ymax=PerIncorrect+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21, fill="white") +ylim(0, 15)+theme_classic()# 21 is filled circle




res <- t.test(spec_test[spec_test$GROUP=='patient',"D1MINUSD2"], spec_test[spec_test$GROUP=='control',"D1MINUSD2"])
res

res <- t.test(spec_test[spec_test$GROUP=='patient',"D0MINUSD1"], spec_test[spec_test$GROUP=='control',"D0MINUSD1"])
res

res <- t.test(spec_test[spec_test$GROUP=='patient',"D0MINUSD2"], spec_test[spec_test$GROUP=='control',"D0MINUSD2"])
res

res <- t.test(spec_test[spec_test$GROUP=='patient',"vcueMINUSncue"], spec_test[spec_test$GROUP=='control',"vcueMINUSncue"])
res

sub_pat        <- pat[pat$DIS=="D0",]
model.pat      <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT)^2 + (1|SUB), data =sub_pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE_CAT|GROUP),details= TRUE)

sub_pat        <- pat[pat$DIS=="D0",]
model.pat      <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT)^2 + (1|SUB), data =sub_pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE_CAT|GROUP),details= TRUE)

sub_pat        <- pat[pat$DIS != "D0",]
model.pat      <- lme4::lmer(MedianRT ~ (GROUP+DIS)^2 + (1|SUB), data =sub_pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~GROUP|DIS),details= TRUE)

sub_pat        <- pat[pat$DIS != "D2",]
model.pat      <- lme4::lmer(MedianRT ~ (GROUP+DIS)^2 + (1|SUB), data =sub_pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~DIS|GROUP),details= TRUE)

summarySE(pat, measurevar="PerCorrect")
summarySE(pat, measurevar="PerIncorrect")
summarySE(pat, measurevar="PerMiss")
summarySE(pat, measurevar="PerFA")
