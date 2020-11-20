library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

#### -------------------------------- Lateralisation Index -------------------------------- #####

rm(list=ls())
name1 <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2 <- "NewAVBroad_AgeContrast_Alpha_LatIndex_AllTrials_p600p1100_7t15Hz_addFreqTime_MinEvoked_80Slct.txt"
#name2 <- "NewAVBroad_AgeContrast_Alpha_WoppIndex_AllTrials_p600p1100_7t15Hz_addFreqTime_MinEvoked_80Slct.txt"

pat   <- read.table(paste0(name1,name2),header=T)

model.pat   <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+TIME+FREQ)^4 + (1|SUB), data =pat)
model_anova <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

pat_yc            <- pat[pat$GROUP == "young",]
pat_oc            <- pat[pat$GROUP == "old",]

model.pat_yc      <- lme4::lmer(POW ~ (CUE_ORIG+TIME)^2 + (1|SUB), data =pat_yc)
model.pat_oc      <- lme4::lmer(POW ~ (CUE_ORIG+TIME)^2 + (1|SUB), data =pat_oc)

model_anova_yc    <- Anova(model.pat_yc,type=2,test.statistic=c("F"))
model_anova_oc    <- Anova(model.pat_oc,type=2,test.statistic=c("F"))

print(model_anova_yc)
lsmeans::cld(lsmeans::lsmeans(model.pat_yc,  "CUE_ORIG"),details= TRUE)

print(model_anova_oc)
lsmeans::cld(lsmeans::lsmeans(model.pat_oc,  pairwise~CUE_ORIG|TIME),details= TRUE)


####-----------------

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","GROUP"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=GROUP, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.2,0.2)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CONC","GROUP","TIME"))

interaction.ABC.plot(POW, x.factor=TIME,
                     groups.factor=CUE_CONC, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),
                                                     ggtitle(""),
                                                     ylim(-0.2,0.2),
                                                     geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))
