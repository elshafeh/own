library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1        <- "/Users/heshamelshafei/GoogleDrive/google_Desktop/14Feb_r_doc/"
ext2        <- "allyc_woppi_information_index.txt" 
pat         <-  read.table(paste0(ext1,ext2),header=T)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN"))

pd <- position_dodge(0.05) 

ggplot(tgc, aes(x=CHAN, y=POW, color=CUE,group=CUE)) + 
  geom_errorbar(aes(ymin=POW-se, ymax=POW+se), width=.1, position=pd,colour="black") +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21,fill="white") +
  ylim(-0.05,0.05)

model.pat      <- lme4::lmer(POW ~ CUE:CHAN + CUE:CHAN:FREQ  + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~CUE|CHAN),details= TRUE)

sub_pat        <-  pat[pat$CHAN == "occ_R",]

sub_model.pat   <- lme4::lmer(POW ~ (CUE+FREQ)^2 + (1|SUB), data =sub_pat)
sub_model_anova <- Anova(sub_model.pat,type=2,test.statistic=c("F"))
print(sub_model_anova)

lsmeans::cld(lsmeans::lsmeans(sub_model.pat,  pairwise~CUE|FREQ),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(sub_model.pat,"CUE"),details= TRUE)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN","FREQ"))

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=CUE, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="",y=""),
                                                 ggtitle(""),ylim(-0.15,0.15),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, 
                                                                            ymin=POW-se),width=0.2)))