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

sub_table   <- read.table("/Users/heshamelshafei/Dropbox/project_bilbo/psych - under construction/Analysis/BilboPilot_JY4R.txt",
                          sep = ',',header=T)

sub_table   <- sub_table[sub_table$tar_length != "120ms",];sub_table$tar_length = factor(sub_table$tar_length)

##### Check Trial Distribution #####

sum_table   <- sub_table %>%
  group_by(tar_length,cue_type,feat_attend,tarClass,proClass)%>%
  mutate(percent = length(cue_type)) %>%
  summarise(max(percent))

col_names      = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

ggplot(sum_table, aes(x=tar_length, y=var,fill=cue_type)) +
  geom_bar(stat="identity", position=position_dodge()) +
  facet_wrap(~feat_attend+tarClass+proClass)+
  scale_fill_brewer(palette="Accent") + 
  theme_minimal()


##### Compare %correct e cue & length#####

sum_table   <- sub_table %>%
  group_by(suj,cue_type,tar_length,feat_attend)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("cue_type","tar_length","feat_attend"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1.5,width=.3)+
  geom_line(size = 1.5,group=1)+
  geom_point(size = 1.5,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+facet_wrap(~cue_type+feat_attend,ncol = 4)+ylim(0,1)

# ggplot()+
#   geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
#   geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
#   theme_cleveland()+facet_wrap(~cue_type+feat_attend,ncol = 4)+ylim(0,1)



##### Compare %correct e length #####

sum_table   <- sub_table %>%
  group_by(suj,tar_length)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("tar_length"))

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1.5,width=.2)+
  geom_line(size = 1.5,group=1)+
  geom_point(size = 1.5,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0,1)

##### Compare %correct e block #####

sum_table   <- sub_table %>%
  group_by(suj,block)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("block"))

ggplot(tgc, aes(x=block, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=block, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=block, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+ylim(0,1)

##### Compare RT e cue,feat and length#####

sum_table   <- sub_table %>%
  group_by(suj,tar_length,cue_type,feat_attend)%>% 
  mutate(sj_rt = median(react_time)) %>%
  summarise(max(sj_rt))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("tar_length")) # "cue_type","feat_attend",

ggplot(tgc, aes(x=tar_length, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+facet_wrap(~cue_type+feat_attend)

##### Compare %correct e feat & length#####

# sum_table   <- sub_table %>%
#   group_by(suj,feat_attend,tar_length)%>%
#   mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
#   summarise(max(percent))
# 
# col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names
# 
# tgc <- summarySE(sum_table, measurevar="var", groupvars=c("feat_attend","tar_length"))
# 
# ggplot(tgc, aes(x=tar_length, y=var)) +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
#   geom_line(size = 1,group=1)+
#   geom_point(size = 1,group=1)+
#   geom_point(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
#   geom_line(data=sum_table,aes(x=tar_length, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
#   theme_cleveland()+facet_wrap(~feat_attend)+ylim(0,1)