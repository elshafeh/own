library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(RColorBrewer)
library(effsize)

## -- CUE (no distractor) : baseline then gfp

rm(list=ls())
ext1        <- "/Users/heshamelshafei/Dropbox/project_me/pub/Papers/phd/paper_age_erp/_prep/doc/"
ext2        <- "4R_age_erp_pe2R_Cue"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

sub_pat     <- pat[pat$CHANNEL=="gmfp",]
ggplot(sub_pat, aes(x=TIME, y=AVG, fill=GROUP)) +
  geom_boxplot()+ylim(0,200)

sub_pat     <- pat[pat$CHANNEL=="Cz.10",]
ggplot(sub_pat, aes(x=TIME, y=AVG, fill=GROUP)) +
  geom_boxplot()+ylim(-20,20)

sub_pat     <- pat[pat$CHANNEL=="Cz.10" & pat$TIME=="1p600p900",c("GROUP","AVG")]
res         <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res$statistic
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="Cz.10" & pat$TIME=="2p900p1200",c("GROUP","AVG")]
res         <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res$statistic
cohen.d(sub_pat,"GROUP",alpha=.05)


sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="1p600p900",c("GROUP","AVG")]
res         <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res$statistic
cohen.d(sub_pat,"GROUP",alpha=.05)


sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="2p900p1200",c("GROUP","AVG")]
res         <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res$statistic
cohen.d(sub_pat,"GROUP",alpha=.05)







