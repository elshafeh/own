library(dae)
library(nlme)
library(effects)
library(psych)
library(interplot)
library(plyr)
library(devtools)
library(ez)
library(Rmisc)
library(wesanderson)
library(lme4)
library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(dplyr)

rm(list=ls())
pd          <- position_dodge(0.1)
sub_table   <- read.table("/Volumes/HESHAM/Bilbo/psych/behav_pilots/Analysis/BilboPilotStructure2R.txt",
                          sep = ',',header=T)

sum_table   <- sub_table %>%
  group_by(cue_type,tar_length,feat_attend)%>%
  mutate(percent = length(cue_length)) %>%
  summarise(max(percent))

col_names      = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

ggplot(sum_table, aes(x=feat_attend, y=var,fill=tar_length)) +
  geom_bar(stat="identity", position=position_dodge()) +
  facet_wrap(~cue_type)+
  scale_fill_brewer(palette="Accent") + 
  theme_minimal()

ggplot(sum_table, aes(x=tar_length, y=var)) +
  geom_bar(stat="identity", position=position_dodge()) +
  facet_wrap(~cue_type+feat_attend)+
  scale_fill_brewer(palette="Accent") + 
  theme_minimal()