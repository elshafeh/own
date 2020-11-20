library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc) ; library(car)
library(wesanderson) ;library(dae)
library(lmerTest)
library(multcompView)

#### -------------------------------- Information Index -------------------------------- #####

rm(list=ls())
name1 <- "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/"
#name2 <- "3Groups_BroadAuditoryOccipital_Information_Index_Baseline_Corrected_MinusEvokedEachCondition.txt"
name2 <-  "3Groups_BroadAuditoryOccipital_Information_Index_Baseline_Corrected_MinusEvokedEachCondition_80Slct.txt"
pat   <- read.table(paste0(name1,name2),header=T)

pat         <- pat[pat$GROUP != "allyoung",];pat$GROUP   <- factor(pat$GROUP);pat$SUB     <- factor(pat$SUB)
pat         <- pat[pat$CHAN == "aud_L" | pat$CHAN == "aud_R" ,];pat$MOD     <- factor(pat$MOD);pat$CHAN    <- factor(pat$CHAN)

model.pat   <- lme4::lmer(POW ~ (GROUP+CUE+CHAN+TIME+FREQ)^5 + (1|SUB), data =pat)
model_anova <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE","CHAN","GROUP"))

interaction.ABC.plot(POW, x.factor=GROUP,
                     groups.factor=CUE, trace.factor=CHAN,
                     data=pat, c,ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),
                                                 ggtitle(""),ylim(-0.1,0.1),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))



yc_pat         <- pat[pat$GROUP == "young",] ; yc_pat$GROUP   <- factor(yc_pat$GROUP) ; yc_pat$SUB   <- factor(yc_pat$SUB)
oc_pat         <- pat[pat$GROUP == "old",]   ; oc_pat$GROUP   <- factor(oc_pat$GROUP) ; oc_pat$SUB   <- factor(oc_pat$SUB)
yc_model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+FREQ)^3 + (1|SUB), data =yc_pat)
oc_model.pat   <- lme4::lmer(POW ~ (CUE+CHAN+FREQ)^3 + (1|SUB), data =oc_pat)
yc_model_anova <- Anova(yc_model.pat,type=2,test.statistic=c("F"))
oc_model_anova <- Anova(oc_model.pat,type=2,test.statistic=c("F"))
print(yc_model_anova)
lsmeans::cld(lsmeans::lsmeans(yc_model.pat,  pairwise~CUE|CHAN),details= TRUE)

print(oc_model_anova)

oc_pat         <- pat[pat$GROUP == "old" & pat$CHAN == "aud_L" ,]
oc_pat$GROUP   <- factor(oc_pat$GROUP) ; oc_pat$SUB   <- factor(oc_pat$SUB);oc_pat$CHAN   <- factor(oc_pat$CHAN)
oc_model.pat   <- lme4::lmer(POW ~ (CUE+FREQ)^2 + (1|SUB), data =oc_pat)
oc_model_anova <- Anova(oc_model.pat,type=2,test.statistic=c("F"))
print(oc_model_anova)
lsmeans::cld(lsmeans::lsmeans(oc_model.pat,  pairwise~CUE|FREQ),details= TRUE)

oc_pat         <- pat[pat$GROUP == "old" & pat$CHAN == "aud_R" ,]
oc_pat$GROUP   <- factor(oc_pat$GROUP) ; oc_pat$SUB   <- factor(oc_pat$SUB);oc_pat$CHAN   <- factor(oc_pat$CHAN)
oc_model.pat   <- lme4::lmer(POW ~ (CUE+FREQ)^2 + (1|SUB), data =oc_pat)
oc_model_anova <- Anova(oc_model.pat,type=2,test.statistic=c("F"))
print(oc_model_anova)
lsmeans::cld(lsmeans::lsmeans(oc_model.pat, "CUE"),details= TRUE)
