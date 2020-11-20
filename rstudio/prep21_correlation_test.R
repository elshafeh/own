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
ext2           <- "prep_21_spearman_correlation_MinEvoked_laterality_time_averaged_sep_freq.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

#pat            <- pat[pat$HEMI == "R_Hemi",] 

model.pat      <- lme4::lmer(SCoeff ~ (CUE_POSITION+FREQ+HEMI)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_POSITION|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~HEMI|CUE_POSITION),details= TRUE)

tgc <- summarySE(pat, measurevar="SCoeff", groupvars=c("CUE_POSITION","HEMI"))

ggplot2::ggplot(tgc, aes(x=HEMI, y=SCoeff, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=SCoeff-se, ymax=SCoeff+se),width=.2,position=position_dodge(.9))+
  ylim(-0.1,0.1)+scale_fill_manual(values=cbPalette)

ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=SCoeff, fill=HEMI)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=SCoeff-se, ymax=SCoeff+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)


sub_pat <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="SCoeff", groupvars=c("CUE_POSITION","HEMI"))

p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=SCoeff, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=SCoeff-se, ymax=SCoeff+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$FREQ == "13Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="SCoeff", groupvars=c("CUE_POSITION","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=SCoeff, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=SCoeff-se, ymax=SCoeff+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("09Hz", "13Hz"))


sub_pat <- pat[pat$HEMI == "L_Hemi",]
sub_pat$HEMI <- factor(sub_pat$HEMI)
tgc <- summarySE(sub_pat, measurevar="SCoeff", groupvars=c("CUE_POSITION","FREQ"))

p1 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=SCoeff, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=SCoeff-se, ymax=SCoeff+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$HEMI == "R_Hemi",]
sub_pat$HEMI <- factor(sub_pat$HEMI)
tgc <- summarySE(sub_pat, measurevar="SCoeff", groupvars=c("CUE_POSITION","FREQ"))

p1 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=SCoeff, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=SCoeff-se, ymax=SCoeff+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Left AcX", "Right AcX"))