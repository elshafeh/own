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
ext2        <- "allyc_PhaseAmplitudeCoupling_p600p1000_2Freq_avgHI.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

pat          <- pat[pat$NORM_TYPE == "nonorm",]
pat$BSL_TYPE <- factor(pat$BSL_TYPE)

model.pat   <- lme4::lmer(POW ~ (CUE+METHOD+LOW_FREQ+BSL_TYPE+CHAN)^5  +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat = pat[pat$METHOD == "tort",]
model.pat   <- lme4::lmer(POW ~ (CUE+LOW_FREQ)^2  +(1|SUB), data =sub_pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|LOW_FREQ),details= TRUE)

sub_pat = pat[pat$METHOD == "canolty" & pat$LOW_FREQ == "09Hz",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","NORM_TYPE"))

p1 = ggplot2::ggplot(tgc, aes(x=NORM_TYPE, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-0.2,0.2)

sub_pat = pat[pat$METHOD == "PLV" & pat$LOW_FREQ == "09Hz",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","NORM_TYPE"))

p2 = ggplot2::ggplot(tgc, aes(x=NORM_TYPE, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-0.2,0.2)

sub_pat = pat[pat$METHOD == "tort" & pat$LOW_FREQ == "09Hz",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","NORM_TYPE"))

p3 = ggplot2::ggplot(tgc, aes(x=NORM_TYPE, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-0.2,0.2)

sub_pat = pat[pat$METHOD == "canolty" & pat$LOW_FREQ == "13Hz",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","NORM_TYPE"))

p4 = ggplot2::ggplot(tgc, aes(x=NORM_TYPE, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-0.2,0.2)

sub_pat = pat[pat$METHOD == "PLV" & pat$LOW_FREQ == "13Hz",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","NORM_TYPE"))

p5 = ggplot2::ggplot(tgc, aes(x=NORM_TYPE, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-0.2,0.2)

sub_pat = pat[pat$METHOD == "tort" & pat$LOW_FREQ == "13Hz",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","NORM_TYPE"))

p6 = ggplot2::ggplot(tgc, aes(x=NORM_TYPE, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  scale_fill_manual(values=cbPalette)#+ ylim(-0.2,0.2)

ggarrange(p1, p2,p3,p4,p5,p6,ncol = 2, nrow = 3,labels = c("canolty 09Hz", "plv 09Hz", "tort 09Hz",
                                                           "canolty 13Hz", "plv 13Hz", "tort 13Hz"))

