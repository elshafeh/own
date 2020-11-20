library(dae);library(nlme);library(effects);
library(psych);library(interplot);library(plyr);
library(devtools);library(ez);library(Rmisc);
library(wesanderson)
library(lme4);library(lsmeans);library(plotly);
library(ggplot2);library(ggpubr);library(dplyr)
library(ggthemes);library(extrafont)
library(car);library(ggplot2)
library(optimx);library(simr)
library(tidyverse)
library(hrbrthemes)
library(viridis)

rm(list=ls())
pd          <- position_dodge(0.1)
alphalev    <- 0.6

# The palette with grey:
cbPalette <- c( "#56B4E9", "#009E73")


sub_table   <- read.table("/Users/heshamelshafei/Dropbox/project_me/pjme_bil/meg/data/bil_behavioralReport.n28.txt",
                          sep = ',',header=T)

sub_table$bloc_nb <- as.factor(sub_table$bloc_nb)

# check all subjects
# [a] create table
sum_table_corr   <- sub_table %>%
  group_by(suj,bloc_nb)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table_corr);
col_names[length((col_names))]  = "var";
names(sum_table_corr)                = col_names

#[b] plot
sum_table_corr %>%
  ggplot( aes(x=suj, y=var)) +
  geom_violin() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_jitter(color="black", size=0.4, alpha=0.9) +
  geom_hline(yintercept = 0.6)+
  geom_hline(yintercept = 0.95)+
  #theme_ipsum() +
  theme(
    plot.title = element_text(size=11)
  ) +
  ggtitle("% Correct") +
  xlab("")

# cerate perc correct table
sum_table_corr   <- sub_table %>%
  group_by(suj,cue_type,feat_attend)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table_corr);
col_names[length((col_names))]  = "var";
names(sum_table_corr)                = col_names

sum_table_corr %>%
  ggplot( aes(x=feat_attend, y=var,fill = feat_attend)) +
  geom_violin() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_jitter(color="black", size=0.4, alpha=0.9,width=0.4) +
  theme(
    plot.title = element_text(size=11)
  ) +
  ggtitle("% Correct") +
  xlab("")+
  facet_wrap(~cue_type)

# tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("cue_type","feat_attend"))

# p1 <- ggplot2::ggplot(tgc, aes(x=cue_type, y=var, fill=feat_attend)) +
#   geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
#   ylim(0,1)+
#   scale_fill_manual(values=cbPalette)+ 
#   scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("% Correct")

## RT

sum_table_rt   <- sub_table %>%
  group_by(suj,cue_type,feat_attend,corr_rep)%>% 
  mutate(sj_rt = median(react_time)/1000) %>%
  summarise(max(sj_rt))

sum_table_rt$corr_rep = factor(sum_table_rt$corr_rep)

col_names = colnames(sum_table_rt);
col_names[length((col_names))]  = "var";
names(sum_table_rt)                = col_names

tgc <- summarySE(sum_table, measurevar="var", groupvars=c("cue_type","feat_attend"))

p3<- ggplot2::ggplot(tgc, aes(x=cue_type, y=var, fill=feat_attend)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
  ylim(0,2)+
  scale_fill_manual(values=cbPalette)+ 
  scale_colour_manual(values=cbPalette)+
  theme_clean()+
  ylab("Reaction time")

# p4<- ggplot2::ggplot(tgc, aes(x=feat_attend, y=var, fill=cue_type)) +
#   geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
#   ylim(0,2)+
#   scale_fill_manual(values=cbPalette)+ 
#   scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("Reaction time")

# per correct per block

sum_table_corr   <- sub_table %>%
  group_by(suj,bloc_nb)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names = colnames(sum_table_corr);
col_names[length((col_names))]  = "var";
names(sum_table_corr)                = col_names

tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("bloc_nb"))

p5 <- ggplot(tgc, aes(x=bloc_nb, y=var)) + 
  geom_point(position=pd, size=2)+
  geom_line(position=pd) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), width=.1, position=pd) +
  ylim(0.65,1)+
  theme_classic2()+
  scale_fill_manual(values=cbPalette)+ 
  scale_colour_manual(values=cbPalette)+
  theme_clean()+
  ylab("% Correct")

sum_table_rt   <- sub_table %>%
  group_by(suj,bloc_nb)%>% 
  mutate(sj_rt = median(react_time)/1000) %>%
  summarise(max(sj_rt))

col_names = colnames(sum_table_rt);
col_names[length((col_names))]  = "var";
names(sum_table_rt)                = col_names

tgc <- summarySE(sum_table_rt, measurevar="var", groupvars=c("bloc_nb"))

p6 <- ggplot(tgc, aes(x=bloc_nb, y=var)) + 
  geom_point(position=pd, size=2)+
  geom_line(position=pd) +
  geom_errorbar(aes(ymin=var-se, ymax=var+se), width=.1, position=pd) +
  ylim(0.5,1.5)+
  theme_classic2()+
  scale_fill_manual(values=cbPalette)+ 
  scale_colour_manual(values=cbPalette)+
  theme_clean()+
  ylab("Reaction time")


## RT per correct

sum_table_rt   <- sub_table %>%
  group_by(suj,corr_rep)%>% 
  mutate(sj_rt = median(react_time)/1000) %>%
  summarise(max(sj_rt))

sum_table_rt$corr_rep = factor(sum_table_rt$corr_rep)

col_names = colnames(sum_table_rt);
col_names[length((col_names))]  = "var";
names(sum_table_rt)                = col_names

sum_table_rt$corr_rep = mapvalues(sum_table_rt$corr_rep, from = c("0", "1"), to = c("incorrect", "correct"))

tgc <- summarySE(sum_table_rt, measurevar="var", groupvars=c("corr_rep"))

p7<- ggplot2::ggplot(tgc, aes(x=corr_rep, y=var)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
  ylim(0,2)+
  #scale_fill_manual(values=cbPalette)+ 
  #scale_colour_manual(values=cbPalette)+
  theme_clean()+
  ylab("Reaction time")


# RT of match % non-match
sum_table_corr   <- sub_table %>%
  group_by(suj,sub_match)%>%
  mutate(sj_rt = median(react_time)/1000) %>%
  summarise(max(sj_rt))

col_names = colnames(sum_table_corr);
col_names[length((col_names))]  = "var";
names(sum_table_corr)                = col_names

sum_table_corr$sub_match = mapvalues(sum_table_corr$sub_match, from = c("0", "1"), to = c("no-match", "match"))

tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("sub_match"))

p8 <- ggplot2::ggplot(tgc, aes(x=sub_match, y=var)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
  ylim(0,2)+
  #scale_fill_manual(values=cbPalette)+ 
  #scale_colour_manual(values=cbPalette)+
  theme_clean()+
  ylab("Reaction time")

# RT of button A/B

sub_table = sub_table[sub_table$rep_button > 0,]

sum_table_corr   <- sub_table %>%
  group_by(suj,rep_button)%>%
  mutate(sj_rt = median(react_time)/1000) %>%
  summarise(max(sj_rt))

col_names = colnames(sum_table_corr);
col_names[length((col_names))]  = "var";
names(sum_table_corr)                = col_names

sum_table_corr$rep_button = mapvalues(sum_table_corr$rep_button, from = c("1", "2"), to = c("A", "B"))

tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("rep_button"))

p9 <- ggplot2::ggplot(tgc, aes(x=rep_button, y=var)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
  ylim(0,2)+
  #scale_fill_manual(values=cbPalette)+ 
  #scale_colour_manual(values=cbPalette)+
  theme_clean()+
  ylab("Reaction time")

ggarrange(p1,p3,p5,p6,p7,p8,p9,ncol = 3, nrow = 3)

# model1          <- lme4::lmer(var ~ (feat_attend+cue_type)^2 + (1|suj), data =sum_table_corr)
# model_anova1     <- Anova(model1,type=2,test.statistic=c("F"))
# print(model_anova1)
# 
# lsmeans(model1,   pairwise~feat_attend|cue_type,details= TRUE)
# lsmeans(model1,   pairwise~cue_type|feat_attend,details= TRUE)
# 
# model2          <- lme4::lmer(var ~ (feat_attend+cue_type)^2 + (1|suj), data =sum_table_rt)
# model_anova2    <- Anova(model2,type=2,test.statistic=c("F"))
# print(model_anova2)
# 
# lsmeans(model2,   pairwise~feat_attend|cue_type,details= TRUE)
# lsmeans(model2,   pairwise~cue_type|feat_attend,details= TRUE)