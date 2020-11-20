library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())
pd <- position_dodge(0.2) # move them .05 to the left and right

ext1                <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/4R/"
ext2                <- "ageingrev_alphatimecourse.txt" 
pat                 <-  read.table(paste0(ext1,ext2),header=T)

model1.pat          <- lme4::lmer(POW ~ (GROUP+CUE_CAT+MOD+HEMI+FREQ_CAT)^5 + (1|SUB), data =pat)
model_anova1        <- Anova(model1.pat,type=2,test.statistic=c("F"))

print(model_anova1)


#pat          <- pat[pat$MOD == "mot",]
#pat$CHAN     <- factor(pat$CHAN) 
#pat$MOD      <- factor(pat$MOD) ;
#pat$HEMI     <- factor(pat$HEMI)

#tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_POSITION","HEMI","FREQ_CAT","GROUP"))

#ggplot2::ggplot(tgc, aes(x=HEMI, y=POW, fill=CUE_POSITION)) +
#  geom_bar(position=position_dodge(), stat="identity") +
#  geom_errorbar(aes(ymin=POW-se, ymax=POW+se),width=.2,position=position_dodge(.9))+
#  ylim(-0.3,0.3)+
#  theme_bw()+
#  facet_wrap(~FREQ_CAT+GROUP)