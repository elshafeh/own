library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "prep21_post_target_alpha_average.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)
pat            <- pat[pat$MOD != "occ",] ;pat$CHAN       <- factor(pat$CHAN) ; pat$MOD       <- factor(pat$MOD) ;pat$HEMI       <- factor(pat$HEMI)

tgc <- summarySE(pat, measurevar="POW", groupvars=c("CUE_CAT","CUE_SIDE","HEMI"))

interaction.ABC.plot(POW, x.factor=CUE_SIDE,
                     groups.factor=CUE_CAT, trace.factor=HEMI,
                     data=pat, c,ggplotFunc=list(labs(x="y",y=""),
                                                 ggtitle(""),
                                                 ylim(-0.25,0),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2)))


model.pat      <- lme4::lmer(POW ~ (CUE_CAT+CUE_SIDE+HEMI+FREQ+TIME)^5 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans(model.pat,  pairwise~CUE_SIDE|HEMI,details= TRUE)
lsmeans(model.pat,  pairwise~CUE_CAT|HEMI,details= TRUE)