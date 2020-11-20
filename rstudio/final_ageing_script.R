library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
#ext1        <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2        <- "14oc_auditory_alpha_no_index_sepTime_sepFreq_alltrials.txt"
#ext2        <- "age_contrast_new_avm_no_index_SepFreq_SepTime.txt"
pat         <-  read.table(paste0(ext1,ext2),header=T)

# pat         <- pat[pat$GROUP == "old",]
# pat$CHAN    <- factor(pat$CHAN)
# pat$MOD    <- factor(pat$MOD)

model.pat      <- lme4::lmer(POW ~ (CUE_ORIG+CHAN+FREQ)^3 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_ORIG|CHAN),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE_ORIG"),details= TRUE)

sub_pat            <- pat[pat$GROUP == "old",]
#sub_pat$MOD    <- factor(sub_pat$MOD)
#sub_pat$CHAN    <- factor(sub_pat$CHAN)

sub_model.pat      <- lme4::lmer(POW ~ (CUE_ORIG+CHAN)^2 + (1|SUB), data =sub_pat)
sub_model_anova    <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_ORIG|CHAN),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  "CUE_ORIG"),details= TRUE)


# sub_pat            <- pat[pat$GROUP == "young",]
# sub_model.pat      <- lme4::lmer(POW ~ (CUE_CONC+CHAN)^2 + (1|SUB), data =sub_pat)
# sub_model_anova    <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
# print(sub_model_anova)
# lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE_CONC|CHAN),details= TRUE)
# lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  "CUE_CONC"),details= TRUE)
 

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","CHAN","FREQ"))

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=CUE_ORIG, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.2,0.2),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se,
                                                                            ymin=POW-se),width=0.2)))

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_ORIG","CHAN"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE_ORIG,group=CUE_ORIG)) +
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.2,0.2)
