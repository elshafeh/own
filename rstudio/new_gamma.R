library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

cbPalette <- c( "#009E73","#E69F00","#999999")

ext1        <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
# ext2        <- "new_gamma_m400m200_baseline.txt"
ext2        <- "new_pre_target_gamma_60t100Hz.txt"
pat         <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(POW ~ (HEMI+CUE_POSITION)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

model_ez <- ezANOVA(pat,dv=.(POW),wid = .(SUB),within = .(HEMI,CUE_POSITION),detailed=T)
print(model_ez)

lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_POSITION"),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.025,0.025)+scale_fill_manual(values=cbPalette)+theme_classic()


ext1        <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "new_post_target_gamma_60t100Hz_tight_wind.txt"
pat         <-  read.table(paste0(ext1,ext2),header=T)
pat         <- pat[pat$TIME != "1500ms",]

model.pat      <- lme4::lmer(POW ~ (HEMI+CUE_POSITION+CUE_CAT)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)


lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_POSITION"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise ~ CUE_POSITION|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise ~ CUE_CAT|HEMI),details= TRUE)

cbPalette <- c( "#009E73","#E69F00","#999999")

sub_pat <- pat[pat$HEMI=="L_Hemi",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","CUE_CAT"))
p2<- ggplot2::ggplot(tgc, aes(x=CUE_CAT, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(0,0.1)+scale_fill_manual(values=cbPalette)+theme_classic()

sub_pat <- pat[pat$HEMI=="R_Hemi",]
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","CUE_CAT"))
p3<- ggplot2::ggplot(tgc, aes(x=CUE_CAT, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(0,0.1)+scale_fill_manual(values=cbPalette)+theme_classic()

ggarrange(p1, p1,p2,p3,ncol = 2, nrow = 2,labels = c("pre", "pre","post-left","post-right"))
