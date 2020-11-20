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

cbPalette <- c("#999999", "#E69F00", "#56B4E9")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "pat22_paper_aud_occ_MedianIAFAdapted0Step_two_freq_sep_time_laterality_with_unf.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI+FREQ)^3 + (1|SUB), data =pat)
model.pat      <- lme4::lmer(POW ~ (CUE_ORIG+HEMI+FREQ)^3 + (1|SUB), data =pat)

model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_POSITION|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, "FREQ"),details= TRUE)

sub_pat        <- pat[pat$FREQ == "09Hz",]
sub_pat        <- pat[pat$FREQ == "13Hz",]

sub_model.pat  <- lme4::lmer(POW ~ (CUE_ORIG+HEMI)^2 + (1|SUB), data =sub_pat)
sub_model.pat  <- lme4::lmer(POW ~ (CUE_ORIG+HEMI)^2 + (1|SUB), data =sub_pat)

sub_pat        <- pat[pat$HEMI == "R_Hemi",]
sub_pat        <- pat[pat$HEMI == "L_Hemi",]

sub_model.pat      <- lme4::lmer(POW ~ (CUE_ORIG+FREQ)^2 + (1|SUB), data =sub_pat)
sub_model.pat      <- lme4::lmer(POW ~ (CUE_ORIG+FREQ)^2 + (1|SUB), data =sub_pat)

sub_model_anova    <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_POSITION|FREQ),details= TRUE)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_ORIG|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  "CUE_ORIG"),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CHAN","CUE_ORIG","FREQ"))

cbPalette <- c( "#56B4E9", "#E69F00","#999999")

sub_pat <- pat[pat$CHAN == "aud_R",]
sub_pat$CHAN <- factor(sub_pat$CHAN)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))

p1 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$CHAN == "aud_L",]
sub_pat$CHAN <- factor(sub_pat$CHAN)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))

p2 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Right AcX", "Left AcX","Right Occipital","Left Occipital"))

cbPalette <- c( "#56B4E9","#999999", "#E69F00")

sub_pat <- pat[pat$CHAN == "aud_R",]
sub_pat$CHAN <- factor(sub_pat$CHAN)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))

p1 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)

sub_pat <- pat[pat$CHAN == "aud_L",]
sub_pat$CHAN <- factor(sub_pat$CHAN)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","FREQ"))

p2 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("Right AcX", "Left AcX","Right Occipital","Left Occipital"))


# sub_pat <- pat[pat$CHAN == "occ_R",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))

# p3 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)
# 
# sub_pat <- pat[pat$CHAN == "occ_L",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
# 
# p4 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.3,0.3)+scale_fill_manual(values=cbPalette)

# interaction.ABC.plot(POW, x.factor=FREQ,
#                      groups.factor=CUE_POSITION, trace.factor=CHAN,
#                      data=pat, c,ggplotFunc=list(labs(x="",y=""),
#                                                  ggtitle(""),
#                                                  ylim(-0.25,0.25),
#                                                  geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2),geom_point(size=2, shape=21,fill="white")))
# 
# 
# pd <- position_dodge(0.1) # move them .05 to the left and right
# 
# ggplot(tgc, aes(x=CUE_POSITION, y=POW, color=CORTEX_POSITION,group=CORTEX_POSITION)) +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
#   geom_line(position=pd) +
#   geom_point(position=pd, size=3, shape=21,fill="white") +
#   ylim(-0.2,0.2)
