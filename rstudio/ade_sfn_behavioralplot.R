# Initiate Libraries ####

library(dae); library(nlme);library(effects);library(psych);library(interplot);
library(plyr);library(devtools);library(ez)
library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly);library(ggplot2);library(ggpubr);library(dplyr);library(scales)
library(ggthemes);library(readr);library(tidyr);library(Hmisc);library(broom)
library(plyr);library(RColorBrewer);library(reshape2);library(tidyverse)

rm(list=ls())

source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

## Sfn Plot Accuracy

# The palette with grey:
cbPalette <- c( "#56B4E9", "#009E73")

my_theme  = "Pastel1"

pd                  <- position_dodge(0.2)

ade_table           <- read.table("~/Dropbox/project_me/pub/Posters/sfn2019/data/ade_meg2R_summary.txt",sep = ',',header=T)

sub_table           <-  ade_table[ade_table$bloc_type =="expe" &
                                    ade_table$n_block != "B010",]

sub_table$nois      <- factor(sub_table$nois)
sub_table$name_comb <- factor(sub_table$name_comb)
sub_table$bloc_type <- factor(sub_table$bloc_type)
sub_table$n_block   <- factor(sub_table$n_block)

sum_table   <- sub_table %>%
  group_by(suj,mod,nois) %>%
  mutate(tot= length(correct), len= sum(correct),percent = len/tot)%>%
  summarise(max(percent))

col_names = colnames(sum_table)
col_names[length((col_names))] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod","nois"))

p1 <- ggplot(tgc, aes(x=nois, y=percent,colour=mod,group=mod)) + 
  geom_point(position=pd, size=2)+
  geom_line(position=pd) +
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.1, position=pd) +
  ylim(0.65,1)+
  theme_classic2()+
  scale_fill_manual(values=cbPalette)+ 
  scale_colour_manual(values=cbPalette)
  
sum_table   <- sub_table %>%
  group_by(suj,mod,nois) %>%
  mutate(tot= length(confide), len= sum(confide),percent = len/tot)%>%
  summarise(max(percent))

col_names = colnames(sum_table)
col_names[length((col_names))] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod","nois"))

p2 <- ggplot(tgc, aes(x=nois, y=percent,colour=mod,group=mod)) + 
  geom_point(position=pd, size=2)+
  geom_line(position=pd) +
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.1, position=pd) +
  ylim(0.2,1)+
  theme_classic()+
  scale_fill_manual(values=cbPalette)+ 
  scale_colour_manual(values=cbPalette)

sum_table   <- sub_table %>%
  group_by(suj,mod,nois) %>%
  mutate(tot= median(rt)/1000)%>%
  summarise(max(tot))

col_names = colnames(sum_table)
col_names[length((col_names))] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod","nois"))

p3 <- ggplot(tgc, aes(x=nois, y=percent,colour=mod,group=mod)) + 
  geom_point(position=pd, size=2)+
  geom_line(position=pd) +
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.1, position=pd) +
  ylim(0.8,1.8)+
  theme_classic()+
  scale_fill_manual(values=cbPalette)+ 
  scale_colour_manual(values=cbPalette)

ggarrange(p1,p2,p3,ncol = 2, nrow = 2)

# p1 <- ggplot(data = sum_table, aes(y = percent, x = nois, fill = mod)) +
#   #geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
#   #geom_point(aes(y = percent, color = mod), position = position_jitter(width = .15), size = .5, alpha = 0.8) +
#   geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5) +
#   guides(fill = FALSE) +
#   guides(color = FALSE) +
#   ylim(0.5,1)+
#   theme_linedraw()+
#   scale_fill_manual(values=cbPalette)+ 
#   scale_colour_manual(values=cbPalette)
