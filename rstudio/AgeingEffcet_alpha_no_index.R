library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
name1 <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
name2 <-  "NewAVBroad_Age_CnD_Alpha_MinEvoked_80Slct_separate_time_separate_freq.txt"

pat     <- read.table(paste0(name1,name2),header=T)

#pat         <- pat[pat$MOD == "Auditory",]
#pat$MOD     <- factor(pat$MOD)
#pat$CHAN    <- factor(pat$CHAN)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+CHAN+FREQ+TIME)^6 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

pat_yc            <- pat[pat$GROUP == "young",]
pat_oc            <- pat[pat$GROUP == "old",]

model.pat_yc      <- lme4::lmer(POW ~ (CUE_ORIG+MOD+HEMI)^3 + (1|SUB), data =pat_yc)
model.pat_oc      <- lme4::lmer(POW ~ (CUE_ORIG+MOD+HEMI)^3 + (1|SUB), data =pat_oc)

model_anova_yc    <- Anova(model.pat_yc,type=2,test.statistic=c("F"))
model_anova_oc    <- Anova(model.pat_oc,type=2,test.statistic=c("F"))

print(model_anova_yc)
print(model_anova_oc)

pat_oc_audL            <- pat[pat$GROUP == "young" & pat$MOD == "aud",]
pat_oc_audR            <- pat[pat$GROUP == "young" & pat$MOD == "vis",]

model.pat_oc_audL      <- lme4::lmer(POW ~ (CUE_ORIG+HEMI)^2 + (1|SUB), data =pat_oc_audL)
model.pat_oc_audR      <- lme4::lmer(POW ~ (CUE_ORIG+HEMI)^2 + (1|SUB), data =pat_oc_audR)

model_anova_oc_audL    <- Anova(model.pat_oc_audL,type=2,test.statistic=c("F"))
model_anova_oc_audR    <- Anova(model.pat_oc_audR,type=2,test.statistic=c("F"))

print(model_anova_oc_audL)
print(model_anova_oc_audR)

lsmeans::cld(lsmeans::lsmeans(model.pat_oc_audL,  pairwise~CUE_ORIG|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat_oc_audR,  pairwise~CUE_ORIG|HEMI),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","CHAN"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.1,0.1)

#aud_broad41_L aud_broad41_R
#aud_broad42_L aud_broad42_R
#aud_broad22_L aud_broad22_R

pat_yc            <- pat[pat$GROUP =="young",]
pat_yc$CHAN       <- factor(pat_yc$CHAN)
pat_yc$GROUP       <- factor(pat_yc$GROUP)

tgc <- summarySE(pat_yc, measurevar="POW", groupvars=c("CUE_ORIG","HEMI","MOD"))

interaction.ABC.plot(POW, x.factor=HEMI,
                     groups.factor=CUE_ORIG, trace.factor=MOD,
                     data=pat_yc, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),
                                                 ggtitle(""),
                                                 ylim(-0.25,0.25),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))
