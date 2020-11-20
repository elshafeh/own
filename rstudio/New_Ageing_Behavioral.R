library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1           <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
ext2           <- "Age_Behavioral_Performance_eCut.txt" 

pat            <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(PerCorrect ~ (GROUP+CUE_CAT+TAR_SIDE+DIS)^2 + (1|SUB), data =pat) # PerCorrect
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,"CUE_CAT"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,"DIS"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE_CAT|GROUP),details= TRUE)

pd <- position_dodge(0.1) # move them .05 to the left and right

tgc <- summarySE(pat, measurevar="MedianRT", groupvars=c("CUE_CAT","GROUP","DIS"))

interaction.ABC.plot(MedianRT, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(geom_point(position=pd, size=3, shape=21,fill="white"),
                                                 geom_line(position=pd,size = 1),
                                                 labs(x="Dis Delay",y="Reaction Time"),
                                                 ggtitle(""),
                                                 ylim(450,650),
                                                 geom_errorbar(data=tgc,position=pd,aes(ymax=MedianRT+se, ymin=MedianRT-se),width=0.2)))


tgc <- summarySE(pat, measurevar="PerCorrect", groupvars=c("CUE_CAT","GROUP","DIS"))

interaction.ABC.plot(PerCorrect, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat, c,ggplotFunc=list(geom_point(position=pd, size=3, shape=21,fill="white"),
                                                 geom_line(position=pd,size = 1),
                                                 labs(x="Dis Delay",y="Reaction Time"),
                                                 ggtitle(""),
                                                 ylim(80,100),
                                                 geom_errorbar(data=tgc,position=pd,aes(ymax=PerCorrect+se, ymin=PerCorrect-se),width=0.2)))

tgc <- summarySE(pat, measurevar="PerCorrect", groupvars=c("DIS"))

pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(tgc, aes(x=DIS, y=PerCorrect)) + 
  geom_errorbar(aes(ymin=PerCorrect-se, ymax=PerCorrect+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd,group=1) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(90,100)

ggplot(data=pat, aes(x=GROUP, y=MedianRT, fill=CUE_CAT)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal()

data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}

pat <- pat[pat$DIS == "D0",]

df3 <- data_summary(pat, varname="MedianRT",groupnames=c("CUE_CAT","GROUP"))

df3[1,3] = -650
df3[2,3] = -600

ggplot(df3, aes(x=GROUP, y=MedianRT, fill=CUE_CAT)) + 
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=MedianRT-sd, ymax=MedianRT+sd), width=.2,
                position=position_dodge(.9)) + 
  theme_classic() + 
  scale_fill_manual(values=c('#999999','#E69F00'))