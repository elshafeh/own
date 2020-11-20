library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(RColorBrewer)
library(export)

rm(list=ls())
pd <- position_dodge(0.1) # move them .05 to the left and right
experiment_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/PTB/ade_behav_pilots/Analysis/ade2R_summary_experiment.txt",sep = ',',header=T)

list_suj    = as.character(unique(experiment_table$n_suj))
list_mod    = as.character(unique(experiment_table$modality))
list_side   = as.character(unique(experiment_table$side))
list_expe   = as.character(unique(experiment_table$nois))
list_design = as.character(unique(experiment_table$design))

table_sum = data.frame(SUB=character(), LAT_LESION=character())

for (nsuj in 1:length(list_suj)){
  for (nmod in 1:length(list_mod)){
    for (nside in 1:length(list_side)){
      for (nexpe in 1:length(list_expe)){
        
        sub_sum   = experiment_table
        sub_sum   = sub_sum[sub_sum$n_suj == list_suj[nsuj],]
        sub_sum   = sub_sum[sub_sum$modality == list_mod[nmod],]
        sub_sum   = sub_sum[sub_sum$side == list_side[nside],]
        sub_sum   = sub_sum[sub_sum$nois == list_expe[nexpe],]
        
        sub_sum$design  = factor(sub_sum$design)
        sub_des         = as.character(unique(sub_sum$design))
        
        sub_corr  = sub_sum[sub_sum$correct == 1,]
        sub_conf  = sub_sum[sub_sum$confidence == 1,]
        
        p_corr    = (lengths(sub_corr)[1]/lengths(sub_sum)[1]) * 100
        p_conf    = (lengths(sub_conf)[1]/lengths(sub_sum)[1]) * 100
        
        tmp       = cbind(list_suj[nsuj],list_mod[nmod],list_side[nside],list_expe[nexpe],sub_des,p_corr,p_conf)
        
        table_sum = rbind(table_sum,tmp)
        
      }
    }
  }
}

names(table_sum) <- c("SUB","MOD","HEMI","NOISE","DESIGN","P_CORR","P_CONF")
table_sum$P_CORR <- as.numeric(levels(table_sum$P_CORR))[table_sum$P_CORR]
table_sum$P_CONF <- as.numeric(levels(table_sum$P_CONF))[table_sum$P_CONF]

## plot boxplot

ggplot(table_sum, aes(x=NOISE, y=P_CORR, fill=HEMI)) + 
  geom_boxplot()+
  facet_wrap(~MOD+DESIGN)+geom_hline(yintercept=75, linetype="dashed", color = "blue")+theme_bw()+ylim(0,100)
ggplot(table_sum, aes(x=NOISE, y=P_CONF, fill=HEMI)) + 
  geom_boxplot()+
  facet_wrap(~MOD+DESIGN)+geom_hline(yintercept=75, linetype="dashed", color = "blue")+theme_bw()+ylim(0,100)


## plot summary with no hemi

tgc <- summarySE(table_sum, measurevar="P_CORR", groupvars=c("MOD","NOISE","NOISE","DESIGN"))

ggplot(tgc, aes(x=NOISE, y=P_CORR)) + 
  geom_errorbar(aes(ymin=P_CORR-se, ymax=P_CORR+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3)+ylim(20,100)+
  theme_bw()+
  geom_hline(yintercept=75, linetype = "dashed",color = "red")+
  facet_wrap(~MOD+DESIGN)

tgc <- summarySE(table_sum, measurevar="P_CONF", groupvars=c("MOD","NOISE","NOISE","DESIGN"))

ggplot(tgc, aes(x=NOISE, y=P_CONF)) + 
  geom_errorbar(aes(ymin=P_CONF-se, ymax=P_CONF+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3)+ylim(20,100)+
  theme_bw()+
  facet_wrap(~MOD+DESIGN)

## plot summary with hemi

tgc <- summarySE(table_sum, measurevar="P_CORR", groupvars=c("MOD","HEMI","NOISE","NOISE","DESIGN"))

ggplot(tgc, aes(x=NOISE, y=P_CORR, colour=HEMI, group=HEMI)) + 
  geom_errorbar(aes(ymin=P_CORR-se, ymax=P_CORR+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(20,100)+
  theme_bw()+
  geom_hline(yintercept=75, linetype = "dashed",color = "red")+
  facet_wrap(~MOD+DESIGN)

tgc <- summarySE(table_sum, measurevar="P_CONF", groupvars=c("MOD","HEMI","NOISE","NOISE","DESIGN"))

ggplot(tgc, aes(x=NOISE, y=P_CONF, colour=HEMI, group=HEMI)) + 
  geom_errorbar(aes(ymin=P_CONF-se, ymax=P_CONF+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(20,100)+
  theme_bw()+
  facet_wrap(~MOD+DESIGN)


## plot single trial 

for (nmod in 1:length(list_mod)){
  for (nexpe in 1:length(list_expe)){
    
    sub_table = experiment_table[experiment_table$modality== list_mod[nmod] & experiment_table$nois == list_expe[nexpe],]
    
    p <- ggplot(sub_table, aes(x=n_trial, y=confidence)) +
      geom_line()+
      geom_point()+
      facet_wrap(~n_suj+side)+ggtitle(paste0(list_mod[nmod],'-',list_expe[nexpe]))+
      geom_hline(yintercept=0, linetype="dashed", color = "red")
    
    print(p)
    
  }
}
