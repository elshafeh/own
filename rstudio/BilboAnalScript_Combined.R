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
alphalev    <- 0.6

sub_table   <- read.table("/Users/heshamelshafei/Dropbox/project_bilbo/psych - under construction/Analysis/BilboPilot_JY4R_vComb.txt",
                          sep = ',',header=T)

sub_table   <- sub_table[sub_table$tar_length == "100ms",];sub_table$tar_length = factor(sub_table$tar_length)
sub_table   <- sub_table[sub_table$MaskCon == "40Con",];sub_table$MaskCon = factor(sub_table$MaskCon)


sum_table   <- sub_table %>%
  group_by(suj,cue_type,feat_attend)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("cue_type","feat_attend"))

ggplot(tgc, aes(x=cue_type, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1.5,width=.3)+
  geom_line(size = 1.5,group=1)+
  geom_point(size = 1.5,group=1)+
  geom_point(data=sum_table,aes(x=cue_type, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=cue_type, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+facet_wrap(~feat_attend,ncol=2) + ylim(0,1)

