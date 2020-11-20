library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(RColorBrewer)
## -- CUE (no distractor) : baseline then gfp

rm(list=ls())
ext1        <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/"
ext2        <- "test4paper_PrepAtt22_gfp2R_young_old_CnD"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

sub_pat     <- pat[pat$TIME=="1p900p1200",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="2p600p900",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

## -- Target (no distractor) : baseline then gfp

rm(list=ls())
ext1        <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/"
ext2        <- "test4paper_PrepAtt22_gfp2R_young_old_nDT"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

sub_pat     <- pat[pat$TIME=="1p70p150",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="2p250p400",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

## -- DISTRACTOR : subtract fake ; baseline then gfp (early)

rm(list=ls())
ext1        <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/"
ext2        <- "test4paper_PrepAtt22_gfp2R_young_old_DIS"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

pat         <- pat[pat$DELAY == "D1",]

sub_pat     <- pat[pat$TIME=="1p40p80",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="2p80p130",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="3p200p250",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="4p290p340",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="5p350p500",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

ggplot(pat, aes(x=TIME, y=AVG, fill=GROUP)) +
  geom_boxplot()+ylim(0,200)


## -- DISTRACTOR : subtract fake ; baseline then gfp (late)

rm(list=ls())
ext1        <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/"
ext2        <- "test4paper_PrepAtt22_gfp2R_young_old_DIS"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

pat         <- pat[pat$DELAY == "D2" & pat$TIME != "5p350p500",]

sub_pat     <- pat[pat$TIME=="1p40p80",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="2p80p130",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="3p200p250",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="4p290p340",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

ggplot(pat, aes(x=TIME, y=AVG, fill=GROUP)) +
  geom_boxplot()+ylim(0,200)

## -- ALL DISTRACTOR : subtract fake ; baseline then gfp

rm(list=ls())
ext1        <- "/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/"
ext2        <- "test4paper_PrepAtt22_gfp2R_young_old_DIS"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)

pat         <- pat[pat$TIME != "5p350p500",]

sub_pat     <- pat[pat$TIME=="1p40p80",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="2p80p130",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="3p200p250",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

sub_pat     <- pat[pat$TIME=="4p290p340",]
res <- t.test(sub_pat[sub_pat$GROUP=='Old',"AVG"], sub_pat[sub_pat$GROUP=='Young',"AVG"])
res

ggplot(pat, aes(x=TIME, y=AVG, fill=GROUP)) +
  geom_boxplot()+ylim(0,200)

