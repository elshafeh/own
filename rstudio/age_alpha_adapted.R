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
ext2           <- "ageing_contrast_broadmann_alpha_cue_effect_minusevoked_FreqAdapted_sep_time"
pat            <-  read.table(paste0(ext1,ext2,".txt"),header=T)

pat            <- pat[pat$MOD == "aud",];pat$CHAN       <- factor(pat$CHAN);pat$MOD        <- factor(pat$MOD)

model.pat_1    <- lme4::lmer(POW ~ (GROUP+HEMI+CUE+FREQ_CAT)^4 + (1|SUB), data =pat)
model_anova_1  <- Anova(model.pat_1,type=2,test.statistic=c("F"))

model.pat_2    <- lme4::lmer(POW ~ (GROUP+HEMI+CUE_POSITION+FREQ_CAT)^4 + (1|SUB), data =pat)
model_anova_2  <- Anova(model.pat_2,type=2,test.statistic=c("F"))

print(model_anova_1)
print(model_anova_2)

sub_pat        <- pat[ pat$HEMI == "R_Hemi",]
model.pat_3    <- lme4::lmer(POW ~ (FREQ_CAT+CUE_POSITION)^2 + (1|SUB), data =sub_pat)
model_anova_3  <- Anova(model.pat_3,type=2,test.statistic=c("F"))

sub_pat        <- pat[ pat$HEMI == "L_Hemi",]
model.pat_4    <- lme4::lmer(POW ~ (FREQ_CAT+CUE_POSITION)^2 + (1|SUB), data =sub_pat)
model_anova_4  <- Anova(model.pat_4,type=2,test.statistic=c("F"))

print(model_anova_3)
print(model_anova_4)

lsmeans::cld(lsmeans::lsmeans(model.pat_4,  pairwise~CUE_POSITION|FREQ_CAT),details= TRUE)

sub_pat        <- pat[pat$FREQ_CAT == "low_freq",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)

sub_pat        <- pat[pat$FREQ_CAT == "high_freq",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.2,0.2)+scale_fill_manual(values=cbPalette)#+theme_classic()

ggarrange(p1, p2, ncol = 2, nrow = 1,labels = c("low alpha", "high alpha"))