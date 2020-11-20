library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(RColorBrewer)

rm(list=ls())
pd <- position_dodge(0.1) # move them .05 to the left and right
staircase_table   <- read.table("/Users/heshamelshafei/Dropbox/ade_project/PTB/ade_behav_pilots/Analysis/ade2R_summary_staircase.txt",sep = ',',header=T)

list_suj  <- as.character(unique(staircase_table$n_suj))
list_mod  <- as.character(unique(staircase_table$modality))
list_side <- as.character(unique(staircase_table$side))
list_bloc <- as.character(unique(staircase_table$n_block))

stair_sum <- data.frame(SUB=character(), LAT_LESION=character())

for (nsuj in 1:length(list_suj)){
  for (nmod in 1:length(list_mod)){
    for (nside in 1:length(list_side)){
      for (nbloc in 1:length(list_bloc)){
        
        sub_sum   = staircase_table
        sub_sum   = sub_sum[sub_sum$n_suj == list_suj[nsuj],]
        sub_sum   = sub_sum[sub_sum$modality == list_mod[nmod],]
        sub_sum   = sub_sum[sub_sum$side == list_side[nside],]
        sub_sum   = sub_sum[sub_sum$n_block == list_bloc[nbloc],]
        
        sub_corr  = sub_sum[sub_sum$response == 'correct',]
        perc      = (lengths(sub_corr)[1]/lengths(sub_sum)[1]) * 100
        
        tmp       = cbind(list_suj[nsuj],list_mod[nmod],list_side[nside],list_bloc[nbloc],perc)
        
        stair_sum = rbind(stair_sum,tmp)
        
      }
    }
  }
}

names(stair_sum) <- c("SUB","MODALITY","HEMISPACE","BLOCK","PERC")
stair_sum$PERC <- as.numeric(levels(stair_sum$PERC))[stair_sum$PERC]

tgc <- summarySE(stair_sum, measurevar="PERC", groupvars=c("HEMISPACE","BLOCK","MODALITY"))
ggplot(tgc, aes(x=BLOCK, y=PERC, colour=HEMISPACE, group=HEMISPACE)) + 
  geom_errorbar(aes(ymin=PERC-se, ymax=PERC+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)+ylim(60,100)+ theme_bw()+geom_hline(yintercept=75, linetype="dashed", color = "black")+facet_wrap(~MODALITY)

# grouped boxplot
ggplot(stair_sum, aes(x=BLOCK, y=PERC, fill=HEMISPACE)) + 
  geom_boxplot()+
  facet_wrap(~MODALITY)+geom_hline(yintercept=75, linetype="dashed", color = "blue")+theme_bw()


# grouped boxplot
ggplot(stair_sum, aes(x=n_trial, y=difference, fill=HEMISPACE)) + 
  geom_boxplot()+
  facet_wrap(~MODALITY)+geom_hline(yintercept=75, linetype="dashed", color = "blue")+theme_bw()


sub_staircase_table = staircase_table[staircase_table$modality=="aud",]

ggplot(sub_staircase_table, aes(x=n_trial, y=difference, group=side)) +
  geom_line(aes(color=side))+
  geom_point(aes(color=side))+
  facet_wrap(~n_suj)