library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/#palettes-color-brewer
# The palette with grey:
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
#cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
#cbPalette <- c("#999999", "#E69F00", "#56B4E9")

cbPalette <- c( "#56B4E9","#999999", "#E69F00")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "pat22_paper_aud_occ_MedianIAFAdapted0Step_two_freq_sep_time_laterality_with_unf.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD == "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI+FREQ)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_POSITION|HEMI),details= TRUE)

sub_pat <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$FREQ == "13Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)#+theme_classic()

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("09Hz", "13Hz"))

sub_pat <- pat
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)#+theme_classic()

sub_pat <- pat
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("FREQ","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=FREQ)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)#+theme_classic()


pat            <- pat[pat$MOD == "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_CAT+FREQ)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CAT"))

ggplot2::ggplot(tgc, aes(x=CUE_CAT, y=POW, fill=CUE_CAT)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0,0.2)+scale_fill_manual(values=cbPalette)#+theme_classic()


# sub_pat <- pat[pat$CHAN == "aud_R",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))
# 
# p1 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)
# 
# sub_pat <- pat[pat$CHAN == "aud_L",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))
# 
# p2 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)+theme_classic()
# 
# ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Right AcX", "Left AcX"))