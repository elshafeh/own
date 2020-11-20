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
ext2        <- "prep21_pre_target_seymourPAC_p600p1000_2_low_sep_high_absolute.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

pat$POW     <- pat$POW/1e+9

model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+LOW_FREQ+METHOD)^4 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat = pat[pat$CHAN == "RHemi",]
model.pat   <- lme4::lmer(POW ~ (CUE+METHOD+LOW_FREQ)^3 +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat = pat[pat$CHAN == "RHemi" & pat$LOW_FREQ == "09Hz",]
model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat = pat[pat$CHAN == "RHemi" & pat$LOW_FREQ == "13Hz",]
model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat = pat[pat$CHAN == "LHemi",]
model.pat   <- lme4::lmer(POW ~ (CUE+METHOD+LOW_FREQ)^3 +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)

sub_pat = pat[pat$METHOD == "MVL",]

tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","CHAN"))

ggplot2::ggplot(tgc, aes(x=CHAN, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)+ ylim(-3,3)

# ggarrange(p1, p2,p3,ncol = 3, nrow = 1,labels = c("no","abs","rel"))
