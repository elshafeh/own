library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
ext1  = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/";

ext2  = "Allyoung.RamaVirtual.AudRPLV.relBSL.txt"
#ext2  = "Allyoung.RamaVirtual.AudRPLV.absBSL.txt"

fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

pat   = pat[pat$FREQ == "7Hz" | pat$FREQ == "8Hz" | pat$FREQ == "9Hz" | pat$FREQ == "10Hz",]
pat   = pat[pat$TIME == "600ms" | pat$TIME == "700ms" | pat$TIME == "800ms" | pat$TIME == "900ms",]

pat$TIME <- factor(pat$TIME)
pat$FREQ <- factor(pat$FREQ)
pat$CHAN <- factor(pat$CHAN)

chan_list <- as.character(unique(pat$CHAN))

pat   = pat[pat$CHAN == chan_list[11] | pat$CHAN == chan_list[42],]
pat$CHAN = factor(pat$CHAN)

model.pat <- lme4::lmer(PLV ~ (CHAN+CUE_CAT+CUE+FREQ+TIME)^4 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

tgc <- summarySE(pat, measurevar="PLV", groupvars=c("CUE_CAT","CUE","FREQ"))

interaction.ABC.plot(PLV, x.factor=CUE,
                     groups.factor=CUE_CAT, trace.factor=FREQ,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(""),ylim(-0.3,0.3),geom_errorbar(data=tgc,aes(ymax=PLV+se, ymin=PLV-se),width=0.2)))  


chan_list <- as.character(unique(pat$CHAN))
freq_list <- as.character(unique(pat$FREQ))

for (nchan in 1:length(chan_list)){

subpat <- pat[pat$CHAN == chan_list[nchan],]

tgc <- summarySE(subpat, measurevar="PLV", groupvars=c("CUE_CAT","CUE","FREQ"))

interaction.ABC.plot(PLV, x.factor=CUE,
                     groups.factor=CUE_CAT, trace.factor=FREQ,
                     data=subpat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),ggtitle(chan_list[nchan]),ylim(-0.5,0.5),geom_errorbar(data=tgc,
                                                                                                                                          aes(ymax=PLV+se, ymin=PLV-se),width=0.2)))

}


subpat <- pat[pat$CHAN == chan_list[1],]

sub_model.pat <- lme4::lmer(PLV ~ (CUE_CAT+CUE+FREQ)^2 + (1|SUB), data =subpat)
sub_a         <-Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE|CUE_CAT),details= TRUE)


subpat <- pat[pat$CHAN == chan_list[1],]
subpat <- subpat[subpat$FREQ == freq_list[4],]

sub_model.pat <- lme4::lmer(PLV ~ (CUE_CAT+CUE)^2 + (1|SUB), data =subpat)
sub_a         <-Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE|CUE_CAT),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_CAT|CUE),details= TRUE)