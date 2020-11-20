library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

rm(list=ls())
ext1=  "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/doc/"
ext2  = "prep21_IAF_AllTrials.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(IAF ~ (CUE_ORIG+HEMI+MOD)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("CUE_ORIG","HEMI","MOD"))

interaction.ABC.plot(IAF, x.factor=CUE_ORIG,
                     groups.factor=HEMI, trace.factor=MOD,
                     data=pat, c,ggplotFunc=list(labs(x="Cue Type",y="Individual ALpha Peak Frequency"),
                                                 ggtitle(""),ylim(7,15),
                                                 geom_errorbar(data=tgc,aes(ymax=IAF+se, ymin=IAF-se),
                                                               width=0.2)))

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~MOD|CUE_ORIG),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~HEMI|CUE_ORIG),details= TRUE)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|MOD),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|HEMI),details= TRUE)
