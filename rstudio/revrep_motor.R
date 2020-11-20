library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

cbPalette      <- c("#E69F00","#009E73","#999999") # c( "#56B4E9","#999999")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "prep21_rep_rev_alpha_motor.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)
pat            <- pat[pat$TIME != "1000ms",] ;pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (CUE_POSITION+HEMI+FREQ)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

b <- ezANOVA(pat,dv=.(POW),wid = .(SUB),within = .(CUE_POSITION,HEMI,FREQ),detailed=T)
print(b)
# n2 = nom / [nom+dom]


lsmeans(model.pat,  pairwise~CUE_POSITION|HEMI,details= TRUE)
lsmeans(model.pat, "FREQ",details= TRUE)

sub_pat        <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ    <- factor(sub_pat$FREQ)
sub_model.pat  <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (1|SUB), data =sub_pat)
sub_model_anova    <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  pairwise~CUE_POSITION|HEMI , details= TRUE)

b <- ezANOVA(sub_pat,dv=.(POW),wid = .(SUB),within = .(CUE_POSITION,HEMI),detailed=T)
print(b)


sub_pat        <- pat[pat$FREQ == "13Hz",]
sub_model.pat  <- lme4::lmer(POW ~ (CUE_POSITION+HEMI)^2 + (1|SUB), data =sub_pat)
sub_model_anova    <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  pairwise~CUE_POSITION|HEMI,details= TRUE)
lsmeans(sub_model.pat,  "HEMI",details= TRUE)

sub_pat         <- pat[pat$HEMI == "R_Hemi",]
sub_pat$HEMI    <- factor(sub_pat$HEMI)
sub_pat$CHAN    <- factor(sub_pat$CHAN)

sub_model.pat   <- lme4::lmer(POW ~ (CUE_POSITION+FREQ)^2 + (1|SUB), data =sub_pat)
sub_model_anova <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  pairwise~CUE_POSITION|FREQ,details= TRUE)

sub_pat         <- pat[pat$HEMI == "L_Hemi",]
sub_model.pat   <- lme4::lmer(POW ~ (CUE_POSITION+FREQ)^2 + (1|SUB), data =sub_pat)
sub_model_anova <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans(sub_model.pat,  "FREQ", details= TRUE)

sub_pat <- pat[pat$FREQ == "09Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.25,0.25)+scale_fill_manual(values=cbPalette)+theme_classic()

sub_pat <- pat[pat$FREQ == "13Hz",]
sub_pat$FREQ <- factor(sub_pat$FREQ)
tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI"))

p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
  ylim(-0.25,0.25)+scale_fill_manual(values=cbPalette)+theme_classic()

ggarrange(p1, p2,ncol = 2, nrow = 1,labels = c("09Hz", "13Hz"))