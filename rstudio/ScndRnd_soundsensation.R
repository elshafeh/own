library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);
library(lme4);library(lsmeans);library(ggplot2);library(RColorBrewer)
library(ggsci);library(ggpubr)


rm(list=ls())
pd <- position_dodge(0.2) # move them .05 to the left and right

ext1                <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/"
ext2                <- "ageing_sensation_values.csv" 
pat                 <-  read.csv(paste0(ext1,ext2),header=T)

pat$group = mapvalues(pat$group, from = c("ocgroup", "ycgroup"), to = c("Elderly", "Young"))

tgc <- summarySE(pat, measurevar="Target_level", groupvars=c("group"))

p1 <- ggplot(tgc, aes(x=group, y=Target_level)) + 
  geom_point(position=pd, size=3,group =1)+
  geom_line(group =1) +
  geom_errorbar(aes(ymin=Target_level-se, ymax=Target_level+se), width=.1, position=pd) +
  ylim(40,70)+
  theme_gdocs()+
  ylab("Target Level (dB)")+
  xlab("Group")

# tgc <- summarySE(pat, measurevar="Threshold", groupvars=c("group"))
# 
# p2 <- ggplot(tgc, aes(x=group, y=Threshold)) + 
#   geom_point(position=pd, size=3,group =1)+
#   geom_line(group =1) +
#   geom_errorbar(aes(ymin=Threshold-se, ymax=Threshold+se), width=.1, position=pd) +
#   ylim(0.5,1)+
#   theme_bw()+
#   ylab("Target Level")+
#   xlab("Group")

tgc <- summarySE(pat, measurevar="Distracor_level", groupvars=c("group"))

p3 <- ggplot(tgc, aes(x=group, y=Distracor_level)) + 
  geom_point(position=pd, size=3,group =1)+
  geom_line(group =1) +
  geom_errorbar(aes(ymin=Distracor_level-se, ymax=Distracor_level+se), width=.1, position=pd) +
  ylim(40,70)+
  theme_gdocs()+
  ylab("Distractor Level (dB)")+
  xlab("Group")

ggarrange(p1, p3,ncol = 2, nrow = 1)



# kruskal.test(Target_level~group,data=pat)
# kruskal.test(Threshold~group,data=pat)
# kruskal.test(Distracor_level~group,data=pat)
