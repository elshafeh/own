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
library(ggthemes)
library(extrafont)

rm(list=ls())

delay_name     <- "CD10"

ext1           <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2           <- paste0("ageingrev_breakdowndis_",delay_name,".txt")
pat            <-  read.table(paste0(ext1,ext2),header=T)

pd <- position_dodge(0.5) # move them .05 to the left and right

point1  = mean(pat[pat$GROUP=="OC" & pat$DELAY=="B0",4])
point2  = mean(pat[pat$GROUP=="YC" & pat$DELAY=="B0",4])
point3  = mean(pat[pat$DELAY=="B0",4])

pat     = pat[pat$DELAY!="B0",]
pat$DELAY = as.factor(pat$DELAY)

tgc <- summarySE(pat, measurevar="MedRT", groupvars=c("DELAY"))

ggplot(tgc, aes(x=DELAY, y=MedRT)) +
  geom_errorbar(aes(ymin=MedRT-se, ymax=MedRT+se), size=1,width=.4,position=pd)+
  geom_line(size = 1,position=pd)+
  geom_point(size = 4,position=pd,shape=21,fill = "white")+
  theme_gdocs()+scale_color_stata()+ylim(300,1000)+
  ylab("Reaction time")+
  xlab("CUE DIS DELAY")
  #geom_hline(aes(yintercept= point3, linetype = "median D0"),linetype="dashed", colour= 'black')

# tgc <- summarySE(pat, measurevar="MedRT", groupvars=c("GROUP","DELAY"))
# 
# ggplot(tgc, aes(x=DELAY, y=MedRT,colour= GROUP,group= GROUP)) +
#   geom_errorbar(aes(ymin=MedRT-se, ymax=MedRT+se), size=1,width=.4,position=pd)+
#   geom_line(size = 1,position=pd)+
#   geom_point(size = 4,position=pd,shape=21,fill = "white")+
#   theme_minimal()+scale_color_stata()+ylim(300,1000)+
#   ylab("Reaction time")+
#   xlab(delay_name)+
#   geom_hline(aes(yintercept= point1, linetype = "median D0 OC"), colour= 'blue')+
#   geom_hline(aes(yintercept= point2, linetype = "median D0 YC"), colour= 'red')+
#   scale_linetype_manual(name = "limit", values = c(2, 2), 
#                         guide = guide_legend(override.aes = list(color = c("blue", "red"))))#+
#   #theme(legend.position="right")
# 
# pat   = pat[pat$DELAY!="B0",]
# pat$DELAY <- factor(pat$DELAY)
# 
# model1.pat  <- lme4::lmer(MedRT ~ (GROUP+DELAY)^2 + (1|SUB), data =pat)
# anova1      <-Anova(model1.pat,type=2,test.statistic=c("F"))
# 
# print(anova1)
# 
# lsmeans(model1.pat,  pairwise~GROUP|DELAY,details= TRUE)
# 
# lsmeans(model1.pat,  pairwise~DELAY|GROUP,details= TRUE)