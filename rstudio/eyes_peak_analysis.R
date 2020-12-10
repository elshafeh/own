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

fname       <- "/Users/heshamelshafei/Documents/GitHub/own/doc/eyes_virt_alphabeta_peak_info.csv"
sub_table   <- read.table(fname,sep = ',',header=T)

sub_table$sub   = as.factor(sub_table$sub)
sub_table$eye   = as.factor(sub_table$eye)
sub_table$roi   = as.factor(sub_table$roi)
sub_table$hemi  = as.factor(sub_table$hemi)

model_peak        <- lme4::lmer(apeak ~ (eye+roi+hemi)^3 + (1|sub), data =sub_table)
model_peak_anova  <- Anova(model_peak,type=2,test.statistic=c("F"))
print(model_peak_anova)

emmeans(model_peak, pairwise ~ hemi | roi)
emmeans(model_peak, pairwise ~ roi)
emmeans(model_peak, pairwise ~ eye | roi)

cbPalette_1         <- c("#FC4E07","#00AFBB") 
cbPalette_2         <-c("#CC6666", "#4E84C4") 

y_lim <- c(5,15)

p1 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("roi p < 0.001") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()

p2 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak, fill=hemi)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("roi*hemi p = 0.01") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_1)+
  scale_fill_manual(values = cbPalette_1)

p3 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak, fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("eyes*hemi p = 0.07") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_2)+
  scale_fill_manual(values = cbPalette_2)

ggarrange(p1,p2,p3,ncol=3,nrow=2)

model_peak        <- lme4::lmer(bpeak ~ (eye+roi+hemi)^3 + (1|sub), data =sub_table)
model_peak_anova  <- Anova(model_peak,type=2,test.statistic=c("F"))
print(model_peak_anova)


y_lim <- c(10,40)

p1 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak frequency") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()

p2 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak, fill=hemi)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak frequency") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_1)+
  scale_fill_manual(values = cbPalette_1)

p3 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak, fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak frequency") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_2)+
  scale_fill_manual(values = cbPalette_2)

ggarrange(p1,p2,p3,ncol=3,nrow=2)