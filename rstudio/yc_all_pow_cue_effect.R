library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

cbPalette <- c( "#009E73","#E69F00","#999999")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "yc_all_BroadandNeigh_alpha_cue_effect_minusevoked.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$MOD != "vis",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

#pat            <- pat[pat$CHAN != "aud_L",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)

new_pat        <- pat[pat$CUE_ORIG == "5Neig",] ; pat$CHAN       <- factor(pat$CHAN)
model.pat      <- lme4::lmer(POW ~ (HEMI+CUE_POSITION+FREQ)^3 + (1|SUB), data =new_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

new_pat        <- pat[pat$CUE_ORIG == "broad",] ; pat$CHAN       <- factor(pat$CHAN)
model.pat      <- lme4::lmer(POW ~ (HEMI+CUE_POSITION+FREQ)^3 + (1|SUB), data =new_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat <-  pat[pat$CUE_ORIG == "5Neig" & pat$HEMI == "L_Hemi",]
sub_pat$CHAN <- factor(sub_pat$CHAN) ; sub_pat$HEMI <- factor(sub_pat$HEMI)

tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))

ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)+ggtitle("Stat Based Left Acx")

sub_pat <-  pat[pat$CUE_ORIG == "5Neig" & pat$HEMI == "R_Hemi",]
sub_pat$CHAN <- factor(sub_pat$CHAN) ; sub_pat$HEMI <- factor(sub_pat$HEMI)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))

ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)+ggtitle("Stat Based Right Acx")

sub_pat <-  pat[pat$CUE_ORIG == "broad" & pat$HEMI == "L_Hemi",]
sub_pat$CHAN <- factor(sub_pat$CHAN) ; sub_pat$HEMI <- factor(sub_pat$HEMI)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))

ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)+ggtitle("Broad Based Left Acx")

sub_pat <-  pat[pat$CUE_ORIG == "broad" & pat$HEMI == "R_Hemi",]
sub_pat$CHAN <- factor(sub_pat$CHAN); sub_pat$HEMI <- factor(sub_pat$HEMI)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))

ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)+ggtitle("Broad Based Right Acx")

# ggarrange(p1, p2 , p3 , p4 , col = 2, nrow = 2,labels = c("Stat Based Left Acx", "Stat Based Right Acx","Broad Based Left Acx", "Broad Based Right Acx"))
