library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())


ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "prep21_supp_and_facilit_MinEvoked_iaf_p600p1000_1Cue_two_occ.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(IAF ~ (MOD+EFFECT+HEMI)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans(model.pat,  "EFFECT" , details= TRUE)
lsmeans(model.pat,  pairwise~MOD|EFFECT , details= TRUE)
lsmeans(model.pat,  pairwise~EFFECT|MOD , details= TRUE)

tgc <- summarySE(pat, measurevar="IAF", groupvars=c("EFFECT","MOD"))

cbPalette <- c("#009E73","#0072B2", "#D55E00")

p1 <- ggplot2::ggplot(tgc, aes(x=MOD, y=IAF, fill=EFFECT)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=IAF-se, ymax=IAF+se),width=.2,position=position_dodge(.9))+
  ylim(0,20)+scale_fill_manual(values=cbPalette)#+theme_classic()

cbPalette <- c("#999999", "#E69F00", "#56B4E9")

p2 <- ggplot2::ggplot(tgc, aes(x=EFFECT, y=IAF, fill=MOD)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=IAF-se, ymax=IAF+se),width=.2,position=position_dodge(.9))+
  ylim(0,20)#+theme_classic()

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Separate By Modality", "Separate By Effect"))
