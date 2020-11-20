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

sub_table   <- read.table("/Users/heshamelshafei/Dropbox/project_bilbo/psych - under construction/Analysis/BilboPilot_JY4R_v2.txt",
                          sep = ',',header=T)

##### Compare %correct e Mask #####

sum_table   <- sub_table %>%
  group_by(suj,MaskCon)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("MaskCon"))

ggplot(tgc, aes(x=MaskCon, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1.5,width=.3)+
  geom_line(size = 1.5,group=1)+
  geom_point(size = 1.5,group=1)+
  geom_point(data=sum_table,aes(x=MaskCon, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=MaskCon, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()

##### Compare %correct e many things mask#####

sum_table   <- sub_table %>%
  group_by(suj,MaskCon,cue_type,feat_attend)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names                         = colnames(sum_table)
col_names[length((col_names))]    = "var"
names(sum_table)                  = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("MaskCon","cue_type","feat_attend"))

ggplot(tgc, aes(x=MaskCon, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1.5,width=.3)+
  geom_line(size = 1.5,group=1)+
  geom_point(size = 1.5,group=1)+
  geom_point(data=sum_table,aes(x=MaskCon, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=MaskCon, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+facet_wrap(~cue_type+feat_attend)


##### Compare %correct e color #####

sum_table   <- sub_table %>%
  group_by(suj,tar_color,block)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table);col_names[length((col_names))]  = "var";names(sum_table)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("tar_color","block"))

ggplot(tgc, aes(x=tar_color, y=var)) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=1,width=.1)+
  geom_line(size = 1,group=1)+
  geom_point(size = 1,group=1)+
  geom_point(data=sum_table,aes(x=tar_color, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  geom_line(data=sum_table,aes(x=tar_color, y=var,colour=suj,group=suj),position=pd,alpha = alphalev)+
  theme_cleveland()+facet_wrap(~block)

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
  theme_cleveland()

