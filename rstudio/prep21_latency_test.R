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
#ext2        <- "ageing_visual_latency_test.txt"
ext2        <- "ageing_all_roi_latency_test.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

model.pat   <- lme4::lmer(LATENCY ~ (GROUP+MOD)^2 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,"GROUP"),details= TRUE)

tgc <- summarySE(pat, measurevar="LATENCY", groupvars=c("GROUP","MOD"))
ggplot2::ggplot(tgc, aes(x=GROUP, y=LATENCY, fill=HEMI)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=LATENCY-se, ymax=LATENCY+se),width=.2,position=position_dodge(.9))+ ylim(0,1)
