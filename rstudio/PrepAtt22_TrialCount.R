library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())


## number of dis trials

fname = "Y:/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/AgeDisTrialNumberByCueCat.txt"
pat <- read.table(fname,header=T)

group_anova <- ezANOVA(pat,dv=.(NTrials),wid = .(SUB),within = .(CUE_CAT),between=.(GROUP),detailed=T)
print(group_anova)

ggplot(pat, aes(x=GROUP, y=NTrials, fill=CUE_CAT)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(50, 90))+theme(text = element_text(size=20))

## NUmebr of Cue trials


fname = "/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/PrepAtt22_TrialCount.txt"
pat <- read.table(fname,header=T)

pat$GROUP <- factor(pat$GROUP)
pat$SUB <- factor(pat$SUB)


group_anova <- ezANOVA(pat,dv=.(Ntrials),wid = .(SUB),within = .(CUE_CAT,CUE_SIDE),between=(GROUP),detailed=T)
print(group_anova)


model.pat <- lme4::lmer(Ntrials ~ (CUE_SIDE+CUE_CAT+GROUP)^3+ (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_CAT|CUE),details= TRUE)

tgc <- summarySE(pat, measurevar="Ntrials", groupvars=c("CUE_CAT","CUE_SIDE","GROUP"))

interaction.ABC.plot(Ntrials, x.factor=CUE_CAT,
                     groups.factor=GROUP, trace.factor=CUE_SIDE,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="# of Trials"),ggtitle(""),ylim(100,115),geom_errorbar(data=tgc,aes(ymax=Ntrials+se, ymin=Ntrials-se),width=0.2)))




pat = pat[pat$GROUP == "young",]
suj_list <- as.character(unique(pat$SUB))

par(mfrow=c(4,4))

for (sub in 1:length(suj_list)){
  
  sub_pat <- pat[pat$SUB == suj_list[sub],]
  
  interaction.plot(sub_pat$CUE_CAT, sub_pat$CUE_SIDE,
                   sub_pat$Ntrials, fun= mean,
                   col=c(4,2,5),lwd = 4, lty = 1, ylim = c(80,130),legend = TRUE,xlab="CueSide", ylab=suj_list[sub])
  
  
}