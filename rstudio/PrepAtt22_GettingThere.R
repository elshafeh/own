library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "ageing_attempt_lat_index_sep_time_sep_freq.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",];pat$CHAN       <- factor(pat$CHAN);pat$MOD        <- factor(pat$MOD)

model.pat      <- lme4::lmer(POW ~ (GROUP+CUE_ORIG+FREQ)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|GROUP),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_ORIG"),details= TRUE)

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.1,0.1)


tgc <- summarySE(pat, measurevar="POW", groupvars=c("FREQ","CUE_ORIG","GROUP"))

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=CUE_ORIG, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),
                                                 ylim(-0.2,0.2),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))




#### ------

# 00ms 01000ms  0100ms  0200ms  0300ms  0400ms  0500ms  0600ms  0700ms  0800ms  0900ms  1100ms  1200ms  1300ms  1400ms  1500ms  1600ms  1700ms  1800ms  1900ms 
# 100Hz 110Hz  50Hz  60Hz  70Hz  80Hz  90Hz 

#pat            <- pat[pat$TIME =="0600ms" | pat$TIME =="0700ms" | pat$TIME =="0800ms" | pat$TIME =="0900ms" | pat$TIME =="1000ms",]
#pat            <- pat[pat$TIME =="1200ms" | pat$TIME =="1300ms" | pat$TIME =="1400ms" | pat$TIME =="1500ms" | pat$TIME =="1600ms" | pat$TIME =="1700ms",]
#pat$TIME       <- factor(pat$TIME)

#pat            <- pat[pat$FREQ =="60Hz" | pat$FREQ =="70Hz" | pat$FREQ =="80Hz" | pat$FREQ =="90Hz",]
#pat$FREQ       <- factor(pat$FREQ)

#pat            <- pat[pat$MOD == "aud",]
#pat$MOD        <- factor(pat$MOD)
#pat$CHAN        <- factor(pat$CHAN)
# 
# sub_pat        <- pat[pat$MOD == "vis",]
# 
# model.pat      <- lme4::lmer(POW ~ (CUE_ORIG+GROUP)^2 + (1|SUB), data =sub_pat)
# model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
# print(model_anova)
# 
# lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|MOD),details= TRUE)
# lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|GROUP),details= TRUE)
# 