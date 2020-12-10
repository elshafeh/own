library(dae);library(nlme);library(effects);
library(psych);library(interplot);library(plyr);
library(devtools);library(ez);library(Rmisc);
library(wesanderson)
library(lme4);library(lsmeans);library(plotly);
library(ggplot2);library(ggpubr);library(dplyr)
library(ggthemes);library(extrafont)
library(car);library(ggplot2)
library(optimx);library(simr)
library(tidyverse)
library(hrbrthemes)
library(viridis);library(afex)
library(multcomp);library(emmeans)

rm(list=ls())
pd          <- position_dodge(0.1)
alphalev    <- 0.6

cbPalette_eyes      <- c("#669933","#FFCC33") 
cbPalette_perf      <- c("#0066CC","#CC0066") 

y_lim <- c(-1,2)

fname       <- "/Users/heshamelshafei/Documents/GitHub/own/doc/eyes_virt_visual_fft.csv"
sub_table   <- read.table(fname,sep = ',',header=T)

sub_table$sub   = as.factor(sub_table$sub)
sub_table$eye   = as.factor(sub_table$eye)
sub_table$rt    = as.factor(sub_table$rt)
sub_table$corr  = as.factor(sub_table$corr)

data_acc        = sub_table[sub_table$rt == "all",]
data_acc$rt     = factor(data_acc$rt)

data_rt         = sub_table[sub_table$rt != "all" & sub_table$corr == "correct",]
data_rt$rt      = factor(data_rt$rt)
data_rt$corr    = factor(data_rt$corr)

model_acc       <- lme4::lmer(pow ~ (eye+corr)^2 + (1|sub), data =data_acc)
model_acc_anova <- Anova(model_acc,type=2,test.statistic=c("F"))
print(model_acc_anova)

model_rt        <- lme4::lmer(pow ~ (eye+rt)^2 + (1|sub), data =data_rt)
model_rt_anova  <- Anova(model_rt,type=2,test.statistic=c("F"))
print(model_rt_anova)

emmeans(model_acc, pairwise ~ corr)
emmeans(model_rt, pairwise ~ rt)

p1 <- data_acc %>%
  ggplot( aes(x=eye, y=pow,fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("eye p < 0.001") +
  xlab("")+scale_colour_manual(values = cbPalette_eyes)+
  scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_fill_manual(values = cbPalette_eyes)

p2 <- data_acc %>%
  ggplot( aes(x=eye, y=pow, fill=corr)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("eye*corr p = 0.04") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_perf)+
  scale_fill_manual(values = cbPalette_perf)



p3 <- data_rt %>%
  ggplot( aes(x=eye, y=pow,fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("eye p < 0.001") +
  xlab("")+scale_colour_manual(values = cbPalette_eyes)+
  scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_fill_manual(values = cbPalette_eyes)

p4 <- data_rt %>%
  ggplot( aes(x=rt, y=pow, fill=rt)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("rt p = 0.16") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_perf)+
  scale_fill_manual(values = cbPalette_perf)

ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)