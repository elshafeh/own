library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
ext1  = "/Users/heshamelshafei/Google\ Drive/PhD/Fieldtripping/R/doc/";
ext2  = "PrepAtt22_TimeResolvedPAC.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

pat   = pat[pat$TIME == "p350p500" | pat$TIME == "p500p650" | pat$TIME == "p650p800" | pat$TIME == "p800p950" | pat$TIME == "p950p1100",]
pat$TIME <- factor(pat$TIME)

model.pat <- lme4::lmer(PAC ~ (CUE_CAT+CUE_SIDE+TIME)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="PAC", groupvars=c("CUE_CAT","CUE_SIDE","TIME"))

interaction.ABC.plot(PAC, x.factor=TIME,
                     groups.factor=CUE_CAT, trace.factor=CUE_SIDE,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(""),ylim(-0.025,0.025),geom_errorbar(data=tgc,aes(ymax=PAC+se, ymin=PAC-se),width=0.2)))

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_CAT|CUE_SIDE),details= TRUE)

