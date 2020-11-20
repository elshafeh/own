library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "pat22_age_separate_roi_contrast_MedianIAF_ModOnly0Step_two_freq_sep_time_laterality_with_unf.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

pat            <- pat[pat$MOD != "occ",];pat$CHAN       <- factor(pat$CHAN);pat$MOD        <- factor(pat$MOD)
pat            <- pat[pat$TIME != "1000ms",] ; pat$TIME       <- factor(pat$TIME)

model.pat      <- lme4::lmer(POW ~ (GROUP+HEMI+CUE_POSITION+FREQ_CAT)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

sub_pat        <-  pat[pat$HEMI == "L_Hemi",]
sub_model.pat   <- lme4::lmer(POW ~ (FREQ_CAT+CUE_ORIG)^2 + (1|SUB), data =sub_pat)
sub_model_anova <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_ORIG|FREQ_CAT),details= TRUE)
# 
# #### ------ 
# 
# tgc <- summarySE(pat, measurevar="POW", groupvars=c("GROUP","HEMI","CUE_POSITION"))
# 
# # pd <- position_dodge(0.1) # move them .05 to the left and right
# # 
# # ggplot(tgc, aes(x=GROUP, y=POW, color=CUE_ORIG,group=CUE_ORIG)) + 
# #   geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
# #   geom_line(position=pd) +
# #   geom_point(position=pd, size=3, shape=21,fill="white") +
# #   ylim(-2,-0.5)
# 
# 
# interaction.ABC.plot(POW, x.factor=HEMI,
#                      groups.factor=CUE_POSITION, trace.factor=GROUP,
#                      data=pat, c,ggplotFunc=list(labs(x="",y=""),
#                                                  ggtitle(""),ylim(-0.25,0.25),
#                                                  geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))
# 
# 
# 
# 
# 
# #### ------ 
# sub_pat <- pat[pat$CHAN == "aud_R" & pat$GROUP == "young",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
# 
# p1 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.15,0.15)+scale_fill_manual(values=cbPalette)
# 
# sub_pat <- pat[pat$CHAN == "aud_R" & pat$GROUP == "old",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
# 
# p2 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.15,0.15)+scale_fill_manual(values=cbPalette)
# 
# sub_pat <- pat[pat$CHAN == "aud_L" & pat$GROUP == "young",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
# 
# p3 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.15,0.15)+scale_fill_manual(values=cbPalette)
# 
# sub_pat <- pat[pat$CHAN == "aud_L" & pat$GROUP == "old",]
# sub_pat$CHAN <- factor(sub_pat$CHAN)
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE_ORIG","FREQ"))
# 
# p4 <- ggplot2::ggplot(tgc, aes(x=FREQ, y=POW, fill=CUE_ORIG)) +geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#   ylim(-0.15,0.15)+scale_fill_manual(values=cbPalette)
# 
# ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2,
#           labels = c("Right AcX Young", "Right AcX Old",
#                      "Left AcX Young", "Left AcX Old"))
