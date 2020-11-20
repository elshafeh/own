library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())
cbPalette <- c( "#009E73","#E69F00","#999999")

ext1        <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "Newprep21_PhaseAmplitudeCoupling_p600p1000_prep21.maxAVMsepVoxels.sepFreq_low.3t20.high5step.50t110_optimisedPACMinEvoked"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

#pat$POW     <- pat$POW/1e+9
#pat         <- pat[pat$NORM_TYPE == "nonorm" & pat$BSL_TYPE ==  "abs",]

model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+LOW_FREQ+METHOD)^4 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)


sub_pat     <- pat[pat$CHAN == "R_Hemi",]
sub_model.pat   <- lme4::lmer(POW ~ (CUE+LOW_FREQ)^2 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  "CUE"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE|LOW_FREQ),details= TRUE)


tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","CHAN"))

ggplot2::ggplot(tgc, aes(x=CHAN, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+scale_fill_manual(values=cbPalette)+
  ylim(-0.05,0.05)

sub_pat     <- pat[pat$LOW_FREQ == "13Hz",]
sub_model.pat   <- lme4::lmer(POW ~ (CUE+CHAN)^2 +(1|SUB), data =sub_pat)
sep_anova   <-Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sep_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE|CHAN),details= TRUE)

tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","CHAN"))

ggplot2::ggplot(tgc, aes(x=CHAN, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+scale_fill_manual(values=cbPalette)+
  ylim(-0.05,0.05)

# model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
# sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))
# 
# print(sep_anova)
# 
# lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)
# 
# 
# lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)
# 
# sub_pat     <- pat[pat$HEMI == "R_Hemi" & pat$LOW_FREQ=="09Hz",]
# 
# model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
# sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))
# 
# print(sep_anova)
# 
# sub_pat     <- pat[pat$HEMI == "R_Hemi" & pat$LOW_FREQ=="13Hz",]
# 
# model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
# sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))
# 
# print(sep_anova)
# 
# lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)
# 
# sub_pat     <- pat[pat$HEMI == "R_Hemi",]
# 
# model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
# sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))
# 
# print(sep_anova)
# 
# lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|METHOD),details= TRUE)
# 
# 
# sub_pat     <- pat[pat$HEMI == "L_Hemi",]
# 
# model.pat   <- lme4::lmer(POW ~ (CUE+METHOD)^2 +(1|SUB), data =sub_pat)
# sep_anova   <-Anova(model.pat,type=2,test.statistic=c("F"))
# 
# print(sep_anova)
# 
# 
# sub_pat     <- pat[pat$LOW_FREQ == "09Hz",]
# tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","CHAN","METHOD"))
# 
# interaction.ABC.plot(POW, x.factor=CHAN,
#                      groups.factor=CUE, trace.factor=METHOD,
#                      data=sub_pat, c,ggplotFunc=list(geom_point(size=3, shape=21,fill="white"),
#                                                  geom_line(size = 0.2),
#                                                  labs(x="",y="% "),
#                                                  ggtitle(""),
#                                                  ylim(-1,1),
#                                                  geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))
# 
# 
# 
# # sub_pat <- pat[pat$METHOD == "canolty",]
# # sub_pat$METHOD <- factor(sub_pat$METHOD)
# # tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","HEMI"))
# # 
# # p1 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
# #   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+scale_fill_manual(values=cbPalette)
# # 
# # sub_pat <- pat[pat$METHOD == "ozkurt",]
# # sub_pat$METHOD <- factor(sub_pat$METHOD)
# # tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","HEMI"))
# # 
# # p2 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
# #   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+scale_fill_manual(values=cbPalette)
# # 
# # sub_pat <- pat[pat$METHOD == "tort",]
# # sub_pat$METHOD <- factor(sub_pat$METHOD)
# # tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","HEMI"))
# # 
# # p3 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
# #   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+scale_fill_manual(values=cbPalette)
# # 
# # sub_pat <- pat[pat$METHOD == "PLV",]
# # sub_pat$METHOD <- factor(sub_pat$METHOD)
# # tgc <- summarySE(sub_pat, measurevar="POW", groupvars=c("CUE","HEMI"))
# # 
# # p4 <- ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE)) +geom_bar(position=position_dodge(), stat="identity") +
# #   geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+scale_fill_manual(values=cbPalette)
# # ggarrange(p1, p2,p3,p4,ncol = 2, nrow = 2,labels = c("can","ozk","tort","plv"))