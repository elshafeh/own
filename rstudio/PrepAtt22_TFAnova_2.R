library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
name1 = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2 =  "3Groups_BroadAuditoryOccipital_Information_Index_Baseline_Corrected_MinusEvokedEachCondition.txt"

pat         <- read.table(paste0(name1,name2),header=T)

pat         <- pat[pat$GROUP != "allyoung",]
pat$GROUP   <- factor(pat$GROUP)
pat$SUB     <- factor(pat$SUB)

pat         <- pat[pat$MOD == "Auditory",]
pat$MOD     <- factor(pat$MOD)
pat$CHAN    <- factor(pat$CHAN)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE+CHAN+TIME+FREQ)^5 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|CHAN),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN","GROUP"))

interaction.ABC.plot(POW, x.factor=CUE,
                     groups.factor=GROUP, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(""),ylim(-0.1,0.1),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


#yc_pat         <- pat[pat$GROUP == "young",] ; yc_pat$GROUP   <- factor(yc_pat$GROUP) ; yc_pat$SUB   <- factor(yc_pat$SUB)
#oc_pat         <- pat[pat$GROUP == "old",]   ; oc_pat$GROUP   <- factor(oc_pat$GROUP) ; oc_pat$SUB   <- factor(oc_pat$SUB)
#yc_model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+TIME+FREQ)^4 + (1|SUB), data =yc_pat)
#oc_model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+TIME+FREQ)^4 + (1|SUB), data =oc_pat)
#yc_model_anova <- Anova(yc_model.pat,type=2,test.statistic=c("F"))
#oc_model_anova <- Anova(oc_model.pat,type=2,test.statistic=c("F"))
#print(yc_model_anova)
#print(oc_model_anova)

audL_pat         <- pat[pat$CHAN == "audL",] ; audL_pat$CHAN   <- factor(audL_pat$CHAN)
audR_pat         <- pat[pat$CHAN == "audR",] ; audR_pat$CHAN   <- factor(audR_pat$CHAN)
audL_model.pat   <- lme4::lmer(POW ~ (CUE+GROUP)^2 + (1|SUB), data =audL_pat)
audR_model.pat   <- lme4::lmer(POW ~ (CUE+GROUP)^2 + (1|SUB), data =audR_pat)
audL_model_anova    <- Anova(audL_model.pat,type=2,test.statistic=c("F"))
audR_model_anova    <- Anova(audR_model.pat,type=2,test.statistic=c("F"))

print(audL_model_anova)
print(audR_model_anova)

#lsmeans::cld(lsmeans::lsmeans(audL_model.pat,  pairwise~CUE|GROUP),details= TRUE)
#lsmeans::cld(lsmeans::lsmeans(audR_model.pat,  pairwise~CUE|GROUP),details= TRUE)
#lsmeans::cld(lsmeans::lsmeans(audL_model.pat,  pairwise~GROUP|CUE),details= TRUE)
#lsmeans::cld(lsmeans::lsmeans(audR_model.pat,  pairwise~GROUP|CUE),details= TRUE)
