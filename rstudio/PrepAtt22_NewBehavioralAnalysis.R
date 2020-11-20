library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1           <- "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "Age_Behavioral_Performance_NewMatch.txt" 
pat            <-  read.table(paste0(ext1,ext2),header=T)

for (ntrl in 1:336){
  pat[ntrl,9] <- paste0(pat[ntrl,2],'_',pat[ntrl,4])
}

names(pat) <- c("SUB","GROUP","PERF","CUE_CAT","DIS","TAR_SIDE", "MedianRT","PerCorrect","GROUP_CUE_CONCAT")
pat$GROUP_CUE_CONCAT <- factor(pat$GROUP_CUE_CONCAT)


model.pat      <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^2 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,   pairwise~DIS|GROUP),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,   "DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,   "CUE_CAT"),details= TRUE)

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("GROUP_CUE_CONCAT","DIS"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot2::ggplot(tgc, aes(x=DIS, y=MedianRT,group=GROUP_CUE_CONCAT,colour=GROUP_CUE_CONCAT)) +
  geom_errorbar(aes(ymin=MedianRT-se, ymax=MedianRT+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3,aes(shape=GROUP_CUE_CONCAT,color=GROUP_CUE_CONCAT,size=GROUP_CUE_CONCAT)) +
  ylim(450,650)+theme_classic()

# tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE_CAT","GROUP","DIS"))
# 
# interaction.ABC.plot(MedianRT, x.factor=DIS,
#                      groups.factor=CUE_CAT, trace.factor=GROUP,
#                      data=pat, c,ggplotFunc=list(labs(x="Dis Delay",y="RT"),
#                                                  ggtitle(""),
#                                                  ylim(400,700),
#                                                  geom_errorbar(data=tgc,aes(ymax=MedianRT+se, ymin=MedianRT-se),width=0.2)))
