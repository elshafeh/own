library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(ggthemes)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2           <- "ageing_sensation_values.csv" 
pat            <-  read.csv(paste0(ext1,ext2),header=T)

pat$GROUP     <- mapvalues(pat$GROUP, from = c("ocgroup", "ycgroup"), to = c("Elderly", "Young"))

#t.test(pat[pat$GROUP=='ocgroup',"Threshold"],pat[pat$GROUP=='ycgroup',"Threshold"], alternative = "two.sided", var.equal = FALSE)
#tgc <- summarySE(pat, measurevar="Threshold", groupvars=c("GROUP"))
#tgc <- summarySE(pat, measurevar="Target_level", groupvars=c("GROUP"))
#tgc <- summarySE(pat, measurevar="Distracor_level", groupvars=c("GROUP"))

p1 <- ggboxplot(pat, x = "GROUP", y = "Threshold", 
          #color = "GROUP",
          ylab = "Threshold", xlab = "")+ 
  ylim(0.4,1)+theme_classic()+theme(text = element_text(color="black",face="bold",size=16,family="Calibri"))


p2 <- ggboxplot(pat, x = "GROUP", y = "Target_level", 
                #color = "GROUP",
                ylab = "Target level", xlab = "")+ 
  ylim(20,80)+theme_classic()+theme(text = element_text(face="bold",size=16,family="Calibri"))

p3 <- ggboxplot(pat, x = "GROUP", y = "Distracor_level", 
                #color = "GROUP",
                ylab = "Distracor level", xlab = "")+ 
  ylim(20,80)+theme_classic()+theme(text = element_text(face="bold",size=16,family="Calibri"))

ggarrange(p1,p2,p3,ncol=3,nrow=1)

