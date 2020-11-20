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
ext2        <- "prep21_pre_target_seymourANDtensorPAC_p600p1000_2_low_sep_abs_not_normalised.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

pat$POW     <- pat$POW/1e+10

model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+LOW_FREQ+METHOD)^4 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat = pat[pat$CHAN == "LHemi",]
model.pat   <- lme4::lmer(POW ~ (CUE+METHOD+LOW_FREQ)^3 +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat = pat[pat$CHAN == "RHemi",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","METHOD"))
p1  <- ggplot2::ggplot(tgc, aes(x=METHOD, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-3,3)

sub_pat = pat[pat$CHAN == "LHemi",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","METHOD"))
p2  <- ggplot2::ggplot(tgc, aes(x=METHOD, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-3,3)


ggarrange(p1, p2,ncol = 1, nrow = 2,labels = c("Right Hemisphere","Left Hemisphere"))
