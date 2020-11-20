library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
ext1  = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/";
ext2  = "AllYoung.DisRamaVirtual.AudLAudR.Gamma.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

model.pat <- lme4::lmer(POW ~ (CHAN+CUE+CUE_CAT+FREQ+TIME)^5 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CAT","TIME","CUE"))

interaction.ABC.plot(POW, x.factor=TIME,
                     groups.factor=CUE_CAT, trace.factor=CUE,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(""),ylim(-1.9e+21,1.9e+21),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


