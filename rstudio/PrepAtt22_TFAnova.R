library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
name1 = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2 =  "BroadMan_AgeContrast_Alpha_LatIndex_AllTrials_p600p1100_7t15Hz_addFreqTime.txt"

pat <- read.table(paste0(name1,name2),header=T)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+FREQ+TIME)^4 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","GROUP","TIME"))

interaction.ABC.plot(POW, x.factor=CUE_ORIG,
                     groups.factor=GROUP, trace.factor=TIME,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(""),ylim(-0.5,0),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CUE_ORIG, y=POW, colour = GROUP)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd)

lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE_ORIG"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|GROUP),details= TRUE)


#----------------------------------------------------------------------------#

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_CAT|CUE),details= TRUE)

yc_pat         <- pat[pat$GROUP == "young",]
yc_pat$GROUP   <- factor(yc_pat$GROUP)
yc_model.pat   <- lme4::lmer(POW ~ (CUE_ORIG+MOD+HEMI+FREQ_CAT)^4 + (1|SUB), data =yc_pat)
yc_model_anova <- Anova(yc_model.pat,type=2,test.statistic=c("F"))

oc_pat         <- pat[pat$GROUP == "old",]
oc_pat$GROUP   <- factor(oc_pat$GROUP)
oc_model.pat   <- lme4::lmer(POW ~ (CUE_ORIG+MOD+HEMI+FREQ_CAT)^4 + (1|SUB), data =yc_pat)
oc_model_anova <- Anova(oc_model.pat,type=2,test.statistic=c("F"))

model.pat      <- lme4::lmer(POW ~ (GROUP+MOD+FREQ_CAT)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

#a1 = ezANOVA (pat, dv = .(POW), wid = .(SUB), within= .(CUE_ORIG,FREQ_CAT), between = .(GROUP), detailed=T)
a1 = ezANOVA (pat, dv = .(POW), wid = .(SUB), within= .(CUE_ORIG,FREQ_CAT), detailed=T)

print(a1)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|CHAN),details= TRUE)


