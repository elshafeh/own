library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
name1 <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2 <-  "BroadAreas_AgeContrast_Alpha_AuditoryOccipital_AllTrials_MinEvoked_RLN_p600p1100_addTimeFreq_80Slct.txt"

pat   <- read.table(paste0(name1,name2),header=T)

pat         <- pat[pat$MOD == "Auditory",]
pat$MOD     <- factor(pat$MOD)
pat$CHAN    <- factor(pat$CHAN)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+FREQ+TIME+CHAN)^5 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

pat_yc            <- pat[pat$GROUP == "young",]
pat_oc            <- pat[pat$GROUP == "old",]

model.pat_yc      <- lme4::lmer(POW ~ (CUE_ORIG+FREQ+CHAN)^3 + (1|SUB), data =pat_yc)
model.pat_oc      <- lme4::lmer(POW ~ (CUE_ORIG+FREQ+CHAN)^3 + (1|SUB), data =pat_oc)

model_anova_yc    <- Anova(model.pat_yc,type=2,test.statistic=c("F"))
model_anova_oc    <- Anova(model.pat_oc,type=2,test.statistic=c("F"))

print(model_anova_yc)
print(model_anova_oc)

pat_oc_audL            <- pat[pat$GROUP == "old" & pat$CHAN == "aud_L",]
pat_oc_audR            <- pat[pat$GROUP == "old" & pat$CHAN == "aud_R",]

model.pat_oc_audL      <- lme4::lmer(POW ~ (CUE_ORIG+FREQ)^2 + (1|SUB), data =pat_oc_audL)
model.pat_oc_audR      <- lme4::lmer(POW ~ (CUE_ORIG+FREQ)^2 + (1|SUB), data =pat_oc_audR)

model_anova_oc_audL    <- Anova(model.pat_oc_audL,type=2,test.statistic=c("F"))
model_anova_oc_audR    <- Anova(model.pat_oc_audR,type=2,test.statistic=c("F"))

print(model_anova_oc_audL)
print(model_anova_oc_audR)

lsmeans::cld(lsmeans::lsmeans(model.pat_oc_audL,  pairwise~CUE_ORIG|FREQ),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","GROUP","CHAN"))

interaction.ABC.plot(POW, x.factor=CUE_ORIG,
                     groups.factor=GROUP, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.15,0.15),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


interaction.ABC.plot(POW, x.factor=CHAN,
                     groups.factor=GROUP, trace.factor=CUE_ORIG,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.15,0.15),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


interaction.ABC.plot(POW, x.factor=CHAN,
                     groups.factor=CUE_ORIG, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.15,0.15),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


interaction.ABC.plot(POW, x.factor=CUE_ORIG,
                     groups.factor=CHAN, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.15,0.15),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))

sub_pat <- pat[pat$GROUP == "young",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","CHAN"))
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.15,.15)

sub_pat <- pat[pat$GROUP == "old" & pat$CHAN == "aud_R",]
sub_pat$GROUP <- factor(sub_pat$GROUP)
sub_pat$CHAN <- factor(sub_pat$CHAN)

tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=FREQ, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.25,.25)

sub_pat <- pat[pat$GROUP == "old" & pat$CHAN == "aud_L",]
sub_pat$GROUP <- factor(sub_pat$GROUP)
sub_pat$CHAN <- factor(sub_pat$CHAN)

tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=FREQ, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.25,.25)