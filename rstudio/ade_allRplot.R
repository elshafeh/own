# Initiate Libraries ####

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

##### Double Check Differences #####

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/Behavioral/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)


sum_table           <-  ade_table[ade_table$nois != 1,]

sum_table$nois      <- factor(sum_table$nois)
sum_table$bloc_type <- factor(sum_table$bloc_type)
sum_table$resp_type <- factor(sum_table$resp_type)
sum_table$conf_type <- factor(sum_table$conf_type)
sum_table$corr_type <- factor(sum_table$corr_type)
sum_table$name_comb <- factor(sum_table$name_comb)

sub_table           <- sum_table[sum_table$mod=="aud" &
                                   sum_table$nois=="3",]

ggplot(sub_table, aes(x=n_trial_tot, y=difference)) +
  geom_line()+
  geom_point(size = 0.5)+
  theme_minimal()+facet_wrap(~suj+design)

##### PLOT Sleep #####

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/scripts_r/ade2R_sleep.txt",sep = ',',header=T)

tgc <- summarySE(ade_table, measurevar="sleep", groupvars=c("design","bloc"))
# tgc <- summarySE(ade_table, measurevar="sleep", groupvars=c("design"))

ggplot(tgc, aes(x=bloc, y=sleep,colour=design,group=design)) + 
  geom_point(position=pd, size=3)+
  geom_line() +
  geom_errorbar(aes(ymin=sleep-se, ymax=sleep+se), width=.1, position=pd) +
  # geom_errorbar(aes(ymin=sleep-sd, ymax=sleep+sd), colour="black", width=.1, position=pd) +
  ylim(1,4)+
  theme_bw()+
  scale_color_brewer(palette="Paired")
  # scale_color_manual(values=wes_palette(n=3, name="GrandBudapest2"))
  # theme_minimal()+



##### PLOT Threshold average #####

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/project_ade/Analysis/Behavioral/scripts_r/ade2R_threshold.txt",sep = ',',header=T)

sub_table <- ade_table[ade_table$mod == "aud",]
tgc <- summarySE(sub_table, measurevar="threshold", groupvars=c("side","design"))

p1= ggplot(tgc, aes(x=design, y=threshold,colour=side,group=side)) + 
  geom_errorbar(aes(ymin=threshold-se, ymax=threshold+se), width=.1, position=pd) +
  geom_line(position=pd) +
  ylim(-40,0)+
  geom_point(position=pd, size=3)+
  theme_bw()

sub_table <- ade_table[ade_table$mod == "vis",]
tgc <- summarySE(sub_table, measurevar="threshold", groupvars=c("side","design"))
p2 = ggplot(tgc, aes(x=design, y=threshold,colour=side,group=side)) + 
  geom_errorbar(aes(ymin=threshold-se, ymax=threshold+se), width=.1, position=pd) +
  geom_line(position=pd) +
  ylim(0,6)+
  geom_point(position=pd, size=3)+
  theme_bw()
            
ggarrange(p1, p2,ncol = 1, nrow = 2,labels = c("A", "V"))

##### PLOT Threshold single subject #####

rm(list=ls())
pd          <- position_dodge(0.3)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/scripts_r/ade2R_threshold.txt",sep = ',',header=T)

sub_table <- ade_table[ade_table$mod == "aud",]

p1= ggplot(sub_table, aes(x=design, y=threshold,colour=side)) + 
  # geom_errorbar(aes(ymin=threshold-se, ymax=threshold+se), width=.1, position=pd) +
  # geom_line(aes()) +
  ylim(-40,0)+
  geom_point(position=pd, size=3)+
  theme_bw()

sub_table <- ade_table[ade_table$mod == "vis",]
p2 = ggplot(sub_table, aes(x=design, y=threshold,colour=side)) + 
  # geom_errorbar(aes(ymin=threshold-se, ymax=threshold+se), width=.1, position=pd) +
  # geom_line(position=pd) +
  ylim(0,6)+
  geom_point(position=pd, size=3)+
  theme_bw()

ggarrange(p1, p2,ncol = 1, nrow = 2,labels = c("A", "V"))




##### PLOT ACCURACY with Staircase #####

rm(list=ls())
pd          <- position_dodge(0.5)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/project_ade/Analysis/Behavioral/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)

sub_table   <-  ade_table[ade_table$nois != "2",]
sub_table$nois <- factor(sub_table$nois)
sub_table$name_comb <- factor(sub_table$name_comb)

sum_table   <- sub_table %>%
  group_by(suj,mod,design,name_comb,side) %>%
  mutate(tot= length(correct), len= sum(correct),percent = len/tot)%>%
  summarise(max(percent))

col_names = colnames(sum_table)
col_names[length((col_names))] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod","side","design","name_comb"))

ggplot(tgc, aes(x=name_comb, y=percent,colour=side,group=side)) +
  geom_line(position=pd) +
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "black")+
  geom_vline(xintercept=c(4.5), linetype="dashed", color = "black")+
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.1, position=pd) +
  geom_point(position=pd, size=3)+ylim(0,1)+
  facet_wrap(~mod+design)+
  # facet_wrap(~design+mod)+
  theme_minimal()

sub_table <- sum_table[sum_table$mod == "vis",]
ggplot(sub_table, aes(x=name_comb, y=percent,colour=side,group=side))+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")+
  geom_line(position=pd) +
  geom_point(position=pd, size=2)+ylim(0,1)+
  facet_wrap(~design+suj,ncol = 6)+
  theme_minimal()

sub_table <- sum_table[sum_table$mod == "aud",]
ggplot(sub_table, aes(x=name_comb, y=percent,colour=side,group=side))+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")+
  geom_line(position=pd) +
  geom_point(position=pd, size=2)+ylim(0,1)+
  facet_wrap(~design+suj,ncol = 6)+
  theme_minimal()

# ggplot(sum_table, aes(x = name_comb, y = percent, color = side,group=side)) +
#   geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")+
#   geom_point(alpha = .4,size = 1,position=pd)+
#   geom_errorbar(data=tgc,aes(ymin=percent-se, ymax=percent+se),width=.8, position=pd)+
#   geom_point(data = tgc,pch = 15,size=2.5,position=pd)+
#   geom_line(data = tgc,position=pd)+
#   facet_wrap(~mod+design)+ylim(0,1)+
#   theme_minimal()


##### PLOT Single trial STAIRCASE #####

rm(list=ls())
pd          <- position_dodge(0.5)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)

sum_table   <- ade_table[ade_table$bloc_type=="stair" & ade_table$mod=="aud",]

ggplot(sum_table, aes(x=n_trial_tot, y=difference)) +
  geom_line(aes())+
  geom_point(size=0.1)+geom_vline(xintercept=c(40,80,120), linetype="dashed", color = "blue")+
  theme_minimal()+
  facet_wrap(~suj+design,ncol = 6)


##### PLOT Experiment #####

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)

sub_table   <-  ade_table[ade_table$nois != 1,]

sub_table$nois <- factor(sub_table$nois)
sub_table$bloc_type <- factor(sub_table$bloc_type)
sub_table$name_comb <- factor(sub_table$name_comb)

sum_table   <- sub_table %>%
  group_by(suj,mod,design,nois,side,name_comb) %>%
  mutate(tot= length(correct), len= sum(correct),percent_corr = len/tot)%>%
  mutate(tot= length(confide), len= sum(confide),percent_conf = len/tot)%>%
  summarise(max(percent_corr),max(percent_conf))

col_names = colnames(sum_table)
col_names[length((col_names))] = "percent_conf"
col_names[length((col_names))-1] = "percent_corr"
names(sum_table) <- col_names

# AVERAGED ACROSS BLOCKS & SUBJECTS

tgc <- summarySE(sum_table, measurevar="percent_corr", groupvars=c("mod","side","design",'nois'))

ggplot(tgc, aes(x=nois, y=percent_corr,colour=side,group=side)) +
  geom_errorbar(aes(ymin=percent_corr-se, ymax=percent_corr+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(0,1)+
  facet_wrap(~mod+design)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")

# AVERAGED ACROSS BLOCKS BUT NOT SUBJECTS

sub_table = sum_table[sum_table$mod=="vis",] # or sub_table = sum_table[sum_table$mod=="aud",]

tgc <- summarySE(sub_table, measurevar="percent_corr", groupvars=c("side","design",'nois','suj'))
ggplot(tgc, aes(x=nois, y=percent_corr,colour=side,group=side)) +
  geom_errorbar(aes(ymin=percent_corr-se, ymax=percent_corr+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(0,1)+
  facet_wrap(~design+suj,ncol = 6)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")

# AVERAGED ACROSS SUBJECTS BUT NOT

tgc <- summarySE(sum_table, measurevar="percent_corr", groupvars=c("mod","side","design",'nois','name_comb'))

ggplot(tgc, aes(x=name_comb, y=percent_corr,colour=side,group=side)) +
  geom_errorbar(aes(ymin=percent_corr-se, ymax=percent_corr+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(0,1)+
  facet_wrap(~mod+design)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")

tgc <- summarySE(sum_table, measurevar="percent_conf", groupvars=c("mod","side","design",'nois'))

ggplot(tgc, aes(x=nois, y=percent_conf,colour=side,group=side)) +
  geom_errorbar(aes(ymin=percent_conf-se, ymax=percent_conf+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(0,1)+
  facet_wrap(~mod+design)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")

tgc <- summarySE(sum_table, measurevar="percent_conf", groupvars=c("mod","side","design",'nois','name_comb'))

ggplot(tgc, aes(x=name_comb, y=percent_conf,colour=side,group=side)) +
  geom_errorbar(aes(ymin=percent_conf-se, ymax=percent_conf+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(0,1)+
  facet_wrap(~mod+design)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")

sub_table = sum_table[sum_table$mod=="vis",]

ggplot(sub_table, aes(x=name_comb, y=percent_conf,colour=side,group=side))+
  geom_line(position=pd) +
  geom_point(position=pd, size=1.5)+ylim(0,1)+
  facet_wrap(~design+suj)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")

sub_table = sum_table[sum_table$mod=="aud",]

ggplot(sub_table, aes(x=name_comb, y=percent_conf,colour=side,group=side))+
  geom_line(position=pd) +
  geom_point(position=pd, size=1.5)+ylim(0,1)+
  facet_wrap(~design+suj)+
  theme_minimal()+
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "grey")


##### PLOT ResponseCatgeories #####

rm(list=ls())
pd                  <- position_dodge(0.1)
ade_table           <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)
sub_table           <-  ade_table[ade_table$nois != 1,]

sub_table$nois      <- factor(sub_table$nois)
sub_table$bloc_type <- factor(sub_table$bloc_type)
sub_table$resp_type <- factor(sub_table$resp_type)
sub_table$conf_type <- factor(sub_table$conf_type)
sub_table$corr_type <- factor(sub_table$corr_type)
sub_table$name_comb <- factor(sub_table$name_comb)

sum_table1   <- sub_table %>%
  group_by(suj,mod,design,nois,side,name_comb,corr_type)%>%
  mutate(tot= length(confide), len= sum(confide),percent = len/tot) %>%
  summarise(max(percent)) %>%
  mutate(confidence = "conf-1")

sum_table2   <- sub_table %>%
  group_by(suj,mod,design,nois,side,name_comb,corr_type)%>%
  mutate(tot= length(confide), len= sum(confide),percent = 1-(len/tot))%>%
  summarise(max(percent)) %>%
  mutate(confidence = "conf-0")

sum_table           = rbind(sum_table1,sum_table2)

col_names = colnames(sum_table)
col_names[length((col_names))-1] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod","design",'nois','corr_type','confidence'))

ggplot(tgc, aes(x=nois, y=percent, fill=confidence)) +
  # geom_boxplot()+
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.2, position=position_dodge(.9))+
  facet_wrap(~design+mod+corr_type)+
  scale_fill_brewer(palette="Accent") + 
  theme_minimal()

##### Plot Single Trial Experiment

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/Analysis/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)

sum_table           <-  ade_table[ade_table$nois != 1,]

sum_table$nois      <- factor(sum_table$nois)
sum_table$bloc_type <- factor(sum_table$bloc_type)
sum_table$resp_type <- factor(sum_table$resp_type)
sum_table$conf_type <- factor(sum_table$conf_type)
sum_table$corr_type <- factor(sum_table$corr_type)
sum_table$name_comb <- factor(sum_table$name_comb)


sub_table           <- sum_table[sum_table$mod=="vis" &
                                   sum_table$nois=="2",]

# sub_table           <- sum_table[sum_table$mod=="vis" &
#                                    sum_table$nois=="2",]
# 
# 
# sub_table           <- sum_table[sum_table$mod=="vis" &
#                                    sum_table$nois=="3",]


ggplot(sub_table, aes(x=n_trial_tot, y=confide,color=side)) +
  geom_line()+
  geom_point(size = 0.2)+
  theme_minimal()+facet_wrap(~suj+design)

ggplot(sub_table, aes(x=n_trial_tot, y=confide)) +
  geom_line()+
  geom_point(size = 0.2)+
  theme_minimal()+facet_wrap(~suj+design)

ggplot(sub_table, aes(x=n_trial_tot, y=correct)) +
  geom_line()+
  geom_point(size = 0.2)+
  theme_minimal()+facet_wrap(~suj+design)
  facet_wrap(~suj+design, ncol = 3)
  
##### Compare Accuracy Modalities #####
  
rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/project_ade/Analysis/Behavioral/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)
sub_table   <-  ade_table[ade_table$nois == "3" & ade_table$design=="new_inter",]
  
sub_table$nois <- factor(sub_table$nois)
sub_table$design <- factor(sub_table$design)
sub_table$name_comb <- factor(sub_table$name_comb)
  
sum_table   <- sub_table %>%
    group_by(suj,mod,name_comb) %>%
    mutate(tot= length(correct), len= sum(correct),percent = len/tot)%>%
    summarise(max(percent))
  
col_names = colnames(sum_table)
col_names[length((col_names))] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod"))

ggplot(tgc, aes(x=mod, y=percent)) +
  geom_line(position=pd) +
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "black")+
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.1, position=pd) +
  geom_point(position=pd, size=3)+
  theme_minimal()

##### Compare Confidence Modalities #####

rm(list=ls())
pd          <- position_dodge(0.1)
ade_table   <- read.table("/Users/heshamelshafei/Dropbox/project_ade/Analysis/Behavioral/scripts_r/ade2R_summary_all.txt",sep = ',',header=T)
sub_table   <-  ade_table[ade_table$nois == "3" & ade_table$design=="new_inter",]

sub_table$nois <- factor(sub_table$nois)
sub_table$design <- factor(sub_table$design)
sub_table$name_comb <- factor(sub_table$name_comb)

sum_table   <- sub_table %>%
  group_by(suj,mod,name_comb) %>%
  mutate(tot= length(confide), len= sum(correct),percent = len/tot)%>%
  summarise(max(percent))

col_names = colnames(sum_table)
col_names[length((col_names))] = "percent"
names(sum_table) <- col_names

tgc <- summarySE(sum_table, measurevar="percent", groupvars=c("mod"))

ggplot(tgc, aes(x=mod, y=percent)) +
  geom_line(position=pd) +
  geom_hline(yintercept=c(0.75,0.5), linetype="dashed", color = "black")+
  geom_errorbar(aes(ymin=percent-se, ymax=percent+se), width=.1, position=pd) +
  geom_point(position=pd, size=3)+
  theme_minimal()