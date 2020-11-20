library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
ext1  = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/";
ext2  = "OldYoung.RamaVirtual.AudLAudR.AlphaGamma.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

#pat   = pat[pat$TIME == "600ms" | pat$TIME == "700ms" | pat$TIME == "800ms" | pat$TIME == "900ms",]
#pat   = pat[pat$FREQ == "7Hz" | pat$FREQ == "8Hz" | pat$FREQ == "9Hz" | pat$FREQ == "10Hz",]

pat   = pat[pat$TIME == "1300ms" | pat$TIME == "1400ms" | pat$TIME == "1500ms" | pat$TIME == "1600ms" | pat$TIME == "1700ms",]
pat   = pat[pat$FREQ == "55Hz" | pat$FREQ == "65Hz" | pat$FREQ == "75Hz" | pat$FREQ == "85Hz" | pat$FREQ == "95Hz",]

pat   = pat[pat$CHAN=="audL",]
pat   = pat[pat$GROUP=="Old",]

pat$TIME <- factor(pat$TIME)
pat$FREQ <- factor(pat$FREQ)
pat$CHAN <- factor(pat$CHAN)
pat$GROUP <- factor(pat$GROUP)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CAT","FREQ","CUE"))

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=CUE_CAT, trace.factor=CUE,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(""),ylim(-0.2,0.2),geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))



model.pat <- lme4::lmer(POW ~ (CUE+CUE_CAT+FREQ+TIME)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_CAT|CUE),details= TRUE)
