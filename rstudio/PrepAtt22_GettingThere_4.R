library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "/Users/heshamelshafei/GoogleDrive/google_Desktop/14Feb_r_doc/"
ext2        <- "3groups_getting_there_no_index.txt" 
pat         <-  read.table(paste0(ext1,ext2),header=T)

pat = pat[pat$GROUP == "allyoung",]

model.pat      <- lme4::lmer(POW ~ CUE:CHAN + CUE:CHAN:FREQ  + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)


tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","CHAN"))

pd <- position_dodge(0.05) 

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.1,0.1)


tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","CHAN","FREQ"))

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=CUE_ORIG, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.2,0.2),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, 
                                                                            ymin=POW-se),width=0.2)))