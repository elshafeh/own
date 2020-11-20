library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
ext1=  "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
ext2  = "AudioVisualbroadman_AgeContrast_IAF_AllTrials_withCueConditions_80Slct.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(IAF ~ (GROUP+CUE+HEMI+MOD)^3 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("MOD","GROUP"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=GROUP, y=IAF, color=MOD,group=MOD)) + 
  geom_errorbar(aes(ymin=IAF-se, ymax=IAF+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(8,14)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("HEMI","GROUP"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=GROUP, y=IAF, color=HEMI,group=HEMI)) + 
  geom_errorbar(aes(ymin=IAF-se, ymax=IAF+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(8,14)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("CUE","MOD","HEMI"))

interaction.ABC.plot(IAF, x.factor=HEMI,
                     groups.factor=CUE, trace.factor=MOD,
                     data=pat, c,
                     ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),
                                     ggtitle(""),ylim(8,14),
                                     geom_errorbar(data=tgc,aes(ymax=IAF+se, ymin=IAF-se),width=0.2)))



sub_pat = pat[pat$MOD == "Auditory",]
sub_model.pat <- lme4::lmer(IAF ~ (CUE+HEMI)^2 + (1|SUB), data =sub_pat)
sub_a         <-Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~HEMI|CUE),details= TRUE)

sub_pat = pat[pat$HEMI == "LHemi",]
sub_model.pat <- lme4::lmer(IAF ~ (CUE+MOD)^2 + (1|SUB), data =sub_pat)
sub_a         <-Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|MOD),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~MOD|CUE),details= TRUE)


