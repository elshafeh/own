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
ext2           <- "yc_all_BroadandNeigh_post_target_gamma_effect_minusevoked.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

new_pat        <- pat[pat$CHAN != "audR_broad",] ; new_pat$CHAN       <- factor(new_pat$CHAN)
model.pat      <- lme4::lmer(POW ~ CUE_POSITION + (1|SUB), data =new_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_POSITION"),details= TRUE)

new_pat        <- pat[pat$CHAN != "audR_5Neigh",] ; new_pat$CHAN       <- factor(new_pat$CHAN)
model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+TIME)^2 + (1|SUB), data =new_pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat <- pat[pat$CHAN == "audR_5Neigh",]
sub_pat$CHAN <- factor(sub_pat$CHAN)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION"))

p1 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.1,0.1)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$CHAN == "audR_broad",]
sub_pat$CHAN <- factor(sub_pat$CHAN)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION"))

p2 <- ggplot2::ggplot(tgc, aes(x=CUE_POSITION, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.1,0.1)+scale_fill_manual(values=cbPalette)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Stat Based", "Broad Based"))