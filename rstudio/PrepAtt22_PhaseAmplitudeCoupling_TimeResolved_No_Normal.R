library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
ext2        <- "BroadAuditoryAreas_PhaseAmplitudeCoupling_NO_normalization_TimeResolved.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

pat         <- pat[pat$TIME =="p300" | pat$TIME =="p450" | pat$TIME == "p600" | pat$TIME =="750" | pat$TIME == "p900",]
pat$TIME    <- factor(pat$TIME)

model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+LOW_FREQ+TIME)^4 + (1|SUB), data =pat)
model_anova <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN","LOW_FREQ","TIME"))

interaction.ABC.plot(POW, x.factor=TIME,
                     groups.factor=CUE, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.1,0.1),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


interaction.ABC.plot(POW, x.factor=LOW_FREQ,
                     groups.factor=CUE, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.1,0.1),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


audL_pat <- pat[pat$CHAN == "aud_L",]
audL_model.pat   <- lme4::lmer(POW ~ (CUE+LOW_FREQ)^2 + (1|SUB), data =audL_pat)
audL_model_anova <-Anova(audL_model.pat,type=2,test.statistic=c("F"))
print(audL_model_anova)

lsmeans::cld(lsmeans::lsmeans(audL_model.pat,  pairwise~CUE|LOW_FREQ),details= TRUE)

audL_model.pat   <- lme4::lmer(POW ~ (CUE+TIME)^2 + (1|SUB), data =audL_pat)
audL_model_anova <-Anova(audL_model.pat,type=2,test.statistic=c("F"))
print(audL_model_anova)

lsmeans::cld(lsmeans::lsmeans(audL_model.pat,  pairwise~CUE|TIME),details= TRUE)

audR_pat <- pat[pat$CHAN == "aud_R",]
audR_model.pat   <- lme4::lmer(POW ~ (CUE+LOW_FREQ)^2 + (1|SUB), data =audR_pat)
audR_model_anova <-Anova(audR_model.pat,type=2,test.statistic=c("F"))
print(audR_model_anova)

lsmeans::cld(lsmeans::lsmeans(audR_model.pat,  pairwise~CUE|LOW_FREQ),details= TRUE)

audR_model.pat   <- lme4::lmer(POW ~ (CUE+TIME)^2 + (1|SUB), data =audR_pat)
audR_model_anova <-Anova(audR_model.pat,type=2,test.statistic=c("F"))
print(audL_model_anova)

lsmeans::cld(lsmeans::lsmeans(audR_model.pat,  pairwise~CUE|TIME),details= TRUE)

sub_pat <- pat[pat$CHAN == "aud_L",] ; sub_pat$CHAN = factor(sub_pat$CHAN)
tgc     <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","TIME"))
pd      <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=TIME, y=POW, color=CUE,group=CUE)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.06,.06)

sub_pat <- pat[pat$CHAN == "aud_L",] ; sub_pat$CHAN = factor(sub_pat$CHAN)
tgc     <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","LOW_FREQ"))
pd      <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=LOW_FREQ, y=POW, color=CUE,group=CUE)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.06,.06)

sub_pat <- pat[pat$CHAN == "aud_R",] ; sub_pat$CHAN = factor(sub_pat$CHAN)
tgc     <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","TIME"))
pd      <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=TIME, y=POW, color=CUE,group=CUE)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.06,.06)

sub_pat <- pat[pat$CHAN == "aud_R",] ; sub_pat$CHAN = factor(sub_pat$CHAN)
tgc     <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","LOW_FREQ"))
pd      <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=LOW_FREQ, y=POW, color=CUE,group=CUE)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.06,.06)