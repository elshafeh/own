library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "/Users/heshamelshafei/GoogleDrive/google_Desktop/14Feb_r_doc/"
ext2        <- "NewBroadAuditoryVisualAreas_PhaseAmplitudeCoupling_normalization_TimeResolved.txt"
pat         <- read.table(paste0(ext1,ext2),header=T)

#pat         <- pat[pat$CHAN =="occ_L" | pat$CHAN == "occ_R",]
pat         <- pat[pat$TIME =="p450" | pat$TIME == "p600" | pat$TIME =="p750" | pat$TIME == "p900",]
pat$TIME    <- factor(pat$TIME)
pat$CHAN    <- factor(pat$CHAN)

#model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+LOW_FREQ+TIME)^4 + (1|SUB), data =pat)
model.pat   <- lme4::lmer(POW ~ CUE:CHAN + (1|SUB), data =pat)

model_anova <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|CHAN),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN","TIME"))

interaction.ABC.plot(POW, x.factor=TIME,
                     groups.factor=CUE, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.1,0.1),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN","LOW_FREQ"))

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
print(audR_model_anova)

lsmeans::cld(lsmeans::lsmeans(audR_model.pat,  pairwise~CUE|TIME),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE,group=CUE)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-.025,.025)