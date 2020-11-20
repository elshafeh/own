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

sub_table   <- read.table("/Volumes/HESHAM/Bilbo/psych/behav_pilots/Analysis/BilboPilot2R_onlyCenter.txt",
                          sep = ',',header=T)

##### Compare %correct e cue,feat and length#####

sum_table   <- sub_table %>%
  group_by(suj,cue_type,feat_attend,tar_length)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("cue_type","feat_attend","tar_length"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0.5,1)+facet_wrap(~cue_type+feat_attend)

##### Compare %correct e length #####

sum_table   <- sub_table %>%
  group_by(suj,tar_length)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("tar_length"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0.5,1)

##### Compare RT e cue,feat and length#####

sum_table   <- sub_table %>%
  group_by(suj,cue_type,feat_attend,tar_length)%>%
  mutate(sj_rt = mean(react_time)) %>%
  summarise(max(sj_rt))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("cue_type","feat_attend","tar_length"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+facet_wrap(~cue_type+feat_attend)

