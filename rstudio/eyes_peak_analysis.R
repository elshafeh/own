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
pd                  <- position_dodge(0.2)
alphalev            <- 0.6

cbPalette_eyes      <- c("#669933","#FFCC33") 

fname               <- "P:/3015039.05/data/all_sub/eyes_virt_alphabeta_peak_info.csv"
sub_table           <- read.table(fname,sep = ',',header=T)

model_peak        <- lme4::lmer(apeak ~ (eye+roi+hemi)^2 + (1|sub), data =sub_table)
model_peak_anova  <- Anova(model_peak,type=2,test.statistic=c("F"))
print(model_peak_anova)

emmeans(model_peak, pairwise ~ roi)
emmeans(model_peak, pairwise ~ eye | roi)
emmeans(model_peak, pairwise ~ roi | eye)

y_lim <- c(5,15)

p1 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("alpha peak: roi p < 0.001") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()

p2 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak, fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("alpha peak: eye*roi p = 0.04") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_eyes)+
  scale_fill_manual(values = cbPalette_eyes)

model_peak        <- lme4::lmer(bpeak ~ (eye+roi+hemi)^3 + (1|sub), data =sub_table)
model_peak_anova  <- Anova(model_peak,type=2,test.statistic=c("F"))
print(model_peak_anova)


y_lim <- c(10,40)

p3 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()

p4 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak, fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_eyes)+
  scale_fill_manual(values = cbPalette_eyes)

ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)