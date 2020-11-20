library(car)
library(ggplot2)
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

rm(list=ls())
pat   = read.table("/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/AllYoungControlGamma.AllYungIndex.AudR.MinEvoked.100Slct.txt",header=T)

pat   = pat[pat$TIME == '1300ms' | pat$TIME == '1400ms' | pat$TIME == '1500ms' | pat$TIME == '1600ms' | pat$TIME == '1700ms' | pat$TIME == '1800ms' | pat$TIME == '1900ms',]
pat$TIME = factor(pat$TIME)

model.pat   <- lme4::lmer(POW ~ (CUE_ORIG+FREQ+TIME)^3 + (1|SUB), data =pat)

model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))

print(model_anova)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("FREQ","CUE","CUE_CAT"))

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=CUE_CAT, trace.factor=CUE,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),
                                                 ggtitle(""),ylim(-0.1,0.1),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_CAT|CUE),details= TRUE)

lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE_ORIG"))

ggplot(pat, aes(x=CUE_ORIG, y=POW,fill=CUE_ORIG)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(-1,1))+
  scale_fill_manual(values=wes_palette(n=3, name="Royal1"))

