library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

cbPalette <- c( "#56B4E9","#999999", "#E69F00")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "prep21_same_filter_alpha_modulation_laterality.txt"
ext2           <- "yc_all_BroadandNeigh_alpha_cue_effect_minusevoked.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$CHAN != "aud_L",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+FREQ)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans(model.pat,  "CUE_POSITION",details= TRUE)

sub_pat <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION"))

p1 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$FREQ == "13Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION"))

p2 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("09Hz", "13Hz"))
