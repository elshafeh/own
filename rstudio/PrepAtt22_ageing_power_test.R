library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
cbPalette <- c( "#009E73","#E69F00","#999999")

ext1        <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "ageing_power_test.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

model.pat   <- lme4::lmer(POW ~ (GROUP+MOD+FREQ+HEMI)^3 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|MOD),details= TRUE)

sub_pat = pat[pat$HEMI == 'L_Hemi',]
model.pat   <- lme4::lmer(POW ~ (GROUP+MOD)^2 +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|MOD),details= TRUE)

sub_pat = pat[pat$HEMI == 'L_Hemi',]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("GROUP","MOD"))

p1 = ggplot2::ggplot(tgc, aes(x=MOD, y=POW, fill=GROUP)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+ ylim(-0.2,0.2)

sub_pat = pat[pat$HEMI == 'R_Hemi',]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("GROUP","MOD"))

p2 = ggplot2::ggplot(tgc, aes(x=MOD, y=POW, fill=GROUP)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+ ylim(-0.2,0.2)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("left hemisphere","right hemisphere"))

tgc <- summarySE(pat, measurevar="POW", groupvars=c("GROUP","MOD"))
ggplot2::ggplot(tgc, aes(x=MOD, y=POW, fill=GROUP)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+ ylim(-0.2,0.2)

