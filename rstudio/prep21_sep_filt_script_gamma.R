library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

#cbPalette <- c("#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c( "#009E73","#E69F00","#999999")

######################### PRE TARGET #################################

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "prep21_separate_filter_gamma_modulation_laterality_sep_freq.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$CHAN != "aud_L",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+FREQ)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_POSITION"),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_POSITION"))

p1 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)

######################### POST TARGET #################################

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
#ext2           <- "prep21_separate_filter_gamma_modulation_laterality_post_target_sep_time.txt"
ext2           <- "prep21_pre_post_target_gamma_unf_separate.txt"

pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
# pat            <- pat[pat$CHAN != "aud_L",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "0600ms",] ; pat <- pat[pat$TIME != "0700ms",] ;
pat            <- pat[pat$TIME != "0800ms",] ; pat <- pat[pat$TIME != "0900ms",] ;
pat            <- pat[pat$TIME != "1000ms",] ; pat <- pat[pat$TIME != "1000ms",] ;
pat            <- pat[pat$TIME != "1100ms",] ; pat <- pat[pat$TIME != "1200ms",] ;
pat            <- pat[pat$TIME != "1700ms",] ; pat <- pat[pat$TIME != "1800ms",] ;

pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+CUE_CAT+HEMI+TIME)^4 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat = pat[pat$CUE_POSITION=="contralateral",]
model.pat      <- lme4::lmer(POW ~ (HEMI+CUE_CAT)^2 + (1|SUB), data =sub_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise ~ CUE_CAT|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE_POSITION"),details= TRUE)

sub_pat = pat[pat$CUE_POSITION=="ipsilateral",]
model.pat      <- lme4::lmer(POW ~ (HEMI+CUE_CAT)^2 + (1|SUB), data =sub_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat, "HEMI"),details= TRUE)


lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise ~ CUE_POSITION|HEMI),details= TRUE)

sub_pat = pat[pat$HEMI=="L_Hemi",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","CUE_CAT"))

p1 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_CAT)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)

sub_pat = pat[pat$HEMI=="R_Hemi",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","CUE_CAT"))

p2 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_CAT)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.05,0.05)+scale_fill_manual(values=cbPalette)


ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Left AcX", "Right AcX"))

