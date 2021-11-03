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
library(multcomp);library(emmeans);
library(gridExtra)

rm(list=ls())

erbar_w             <- .6; erbar_s <- .8; pd  <- position_dodge(erbar_w+.1)
scat_s              <- 1.5;mean_s  <- 5; font_s  <- 16

dir_file            <- "/Users/heshamelshafei/gitHub/own/doc/"
fname               <- paste0(dir_file,"pam_alpha_peak.txt")
sub_table           <- read.table(fname,sep = ',',header=T)

sub_table$sub       <- as.factor(sub_table$sub)
sub_table$mod       <- as.factor(sub_table$mod)
sub_table$hemi      <- as.factor(sub_table$hemi)
sub_table$wind      <- as.factor(sub_table$wind)
sub_table$cue       <- as.factor(sub_table$cue)
sub_table$cue_cat   <- as.factor(sub_table$cue_cat)
sub_table$pos       <- as.factor(sub_table$pos)

sub_table$wind      <- ordered(sub_table$wind, levels = c("precue", "cuetarget"))
sub_table$cue       <- ordered(sub_table$cue, levels = c("left", "right","unf"))

model_glm           <- lme4::lmer(peak ~ (mod+hemi+wind)^3 + (1|sub), data =sub_table)
model_anova         <- Anova(model_glm,type=2,test.statistic=c("F"))
print(model_anova)

emmeans(model_glm, pairwise ~ hemi|mod)

ct_table            <- sub_table[sub_table$wind == "cuetarget",]

model_glm           <- lme4::lmer(peak ~ (mod+pos+cue)^3 + (1|sub), data =ct_table)
model_anova         <- Anova(model_glm,type=2,test.statistic=c("F"))
print(model_anova)

ct_table            <- sub_table[sub_table$wind == "cuetarget" & sub_table$mod =="aud",]

model_glm           <- lme4::lmer(peak ~ (cue+pos)^2 + (1|sub), data =ct_table)
model_anova         <- Anova(model_glm,type=2,test.statistic=c("F"))
print(model_anova)

emmeans(model_glm, pairwise ~ pos|cue)

map_name            <- c("#70ba8d","#7098ba")

ggplot(sub_table, aes(x = mod, y = peak, fill = hemi)) +
  geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
  scale_colour_manual(values= map_name)+
  scale_fill_manual(values = map_name)+
  ggtitle("")+
  scale_y_continuous(name = "alpha peak",limits = c(5,15))+
  scale_x_discrete(name = "")+
  theme_pubclean(base_size = 18,base_family = "Calibri")+
  facet_wrap(~ wind~cue)



