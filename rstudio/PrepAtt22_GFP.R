library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)

rm(list=ls())

#fname = "/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/R/doc/PrepAtt22_gfp2R_CnD_p600p1100_slidWindows.txt"
fname = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/PrepAtt22_gfp2R_CnD_p600p1100_slidWindows.txt"

pat_group <- read.table(fname,header=T, sep="\t")

group_anova <- ezANOVA(pat_group,dv=.(AVG),wid = .(SUB),within = .(TAR_SIDE,CUE_CAT,TIME),between = .(GROUP),detailed=T)
print(group_anova)

tgc <- summarySE(pat_group, measurevar="AVG", groupvars=c("CUE_CAT","GROUP","TIME"))

interaction.ABC.plot(AVG, x.factor=TIME,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat_group, c,ggplotFunc=list(ylim(20,50),geom_errorbar(data=tgc,
                                                                                aes(ymax=AVG+se, ymin=AVG-se),width=0.2)))

position_dodge(width = 0.9)

pat_oc = pat_group[pat_group$GROUP=='Old',]
pat_oc$SUB <- factor(pat_oc$SUB)
pat_oc$GROUP <- factor(pat_oc$GROUP)

oc_anova <- ezANOVA(pat_oc,dv=.(AVG),wid = .(SUB),within = .(CUE_CAT,TIME),detailed=T)
print(oc_anova)

pat_yc = pat_group[pat_group$GROUP=='Young',]
pat_yc$SUB <- factor(pat_yc$SUB)
pat_yc$GROUP <- factor(pat_yc$GROUP)

yc_anova <- ezANOVA(pat_yc,dv=.(AVG),wid = .(SUB),within = .(CUE_CAT,TIME),detailed=T)
print(yc_anova)

cue_cat_time<-pairwise.t.test(pat_yc$AVG,pat_yc$CUE_CAT,paired=TRUE,p.adjust.method="fdr")
print(cue_cat_time)