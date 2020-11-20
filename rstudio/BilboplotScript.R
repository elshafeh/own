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

sub_table   <- read.table("/Volumes/HESHAM/Bilbo/psych/behav_pilots/Analysis/BilboPilot2R.txt",
                          sep = ',',header=T)

##### Compare %correct peri/cent #####

sum_table   <- sub_table %>%
  group_by(suj,pres_type)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("pres_type"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0.4,1)


##### Compare %correct peri/cent & target length#####

sum_table   <- sub_table %>%
  group_by(suj,pres_type,tar_length)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("pres_type","tar_length"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0.4,1)+facet_wrap(~pres_type)

##### Compare %correct peri/cent & feature #####

sum_table   <- sub_table %>%
  group_by(suj,pres_type,feat_attend)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("pres_type","feat_attend"))

ggplot(tgc, aes(x=feat_attend, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=feat_attend, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=feat_attend, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0.4,1)+facet_wrap(~pres_type)


##### Compare Order of blocks #####

sum_table   <- sub_table %>%
  group_by(suj,block_tot,suj_type)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("block_tot","suj_type"))

ggplot(tgc, aes(x=block_tot, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=block_tot, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=block_tot, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0.4,1)+facet_wrap(~suj_type)

#####  Check Trial Number #####

sum_table   <- sub_table %>%
  group_by(pres_type,cue_type,tar_length,feat_attend)%>%
  mutate(percent = length(cue_length)) %>%
  summarise(max(percent))

col_names      = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table) = col_names

ggplot(sum_table, aes(x=tar_length, y=var)) +
  geom_bar(stat="identity", position=position_dodge()) +
  facet_wrap(~pres_type+cue_type+feat_attend)+
  scale_fill_brewer(palette="Accent") + 
  theme_minimal()

#####  Compare  Reaction Time #####

sum_table   <- sub_table %>%
  group_by(suj,pres_type)%>%
  mutate(sj_rt = median(react_time)) %>%
  summarise(max(sj_rt))

col_names      = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table) = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("pres_type"))

ggplot(tgc, aes(x=pres_type, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.08)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=pres_type, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=pres_type, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(400,2500)

#####  Compare  Reaction Time between correct and incorrect #####

sub_table$corr_rep <- factor(sub_table$corr_rep)

sum_table   <- sub_table %>%
  group_by(suj,pres_type,corr_rep)%>%
  mutate(sj_rt = median(react_time)) %>%
  summarise(max(sj_rt))

col_names      = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table) = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("pres_type","corr_rep"))

ggplot(tgc, aes(x=corr_rep, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.08)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=corr_rep, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=corr_rep, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(400,2500)+facet_wrap(~pres_type)
