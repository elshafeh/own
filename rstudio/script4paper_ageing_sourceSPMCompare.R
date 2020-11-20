library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)
library(RColorBrewer)

## -- CUE early

rm(list=ls())

labels      <- read.table("~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/clusters_labels.csv",header=T,sep = ",")

ext1         <- "~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/"
# ext2         <- "cue_600-900_4R.csv"
ext2         <- "cue_900-1200_4R.csv"
pat          <- read.table(paste0(ext1,ext2),header=T,sep = ",")
pat$num_area <- factor(pat$num_area)

for (nline in 1:nrow(pat)){
  
  list_group = c('old','young')
  pat[nline,6] = list_group[length(grep('yc',as.character(pat[nline,1])))+1]
  
}

names(pat) <- c("SUB","CUE","MEANPOW","MAXABSPOW","AREA","GROUP")
pat$GROUP <- factor(pat$GROUP)

model.pat   <- lme4::lmer(MEANPOW ~ (GROUP+CUE+AREA)^3 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|AREA),details= TRUE) # 4 (<0.0001), 5(0.01), 6(0.0001) 

sub_pat = pat[pat$AREA =='4' | pat$AREA =='5' | pat$AREA =='6',]
sub_pat$AREA <- factor(sub_pat$AREA)

levels(sub_pat$AREA) <- c("PreCentG_L","PreCentG_R","IFG_MFG_L")

ggplot(sub_pat, aes(x=AREA, y=MEANPOW, fill=GROUP)) +
  geom_boxplot()+scale_fill_manual(values=c("#9999CC", "#66CC99")) + ylim(-1,1)


## -- Target

rm(list=ls())

ext1         <- "~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/"
ext2         <- "target_250-400_4R.csv" #target_70-150_4R.csv #target_250-400_4R.csv
pat          <- read.table(paste0(ext1,ext2),header=T,sep = ",")
pat$num_area <- factor(pat$num_area)

for (nline in 1:nrow(pat)){
  
  list_group = c('old','young')
  pat[nline,6] = list_group[length(grep('yc',as.character(pat[nline,1])))+1]
  
}

names(pat) <- c("SUB","CUE","MEANPOW","MAXABSPOW","AREA","GROUP")
pat$GROUP <- factor(pat$GROUP)

model.pat   <- lme4::lmer(MEANPOW ~ (GROUP+CUE+AREA)^3 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|AREA),details= TRUE)

# N1: 1 = 0.049 ,, 3 = 0.002
# sub_pat = pat[pat$AREA =='1' | pat$AREA =='3',]
# sub_pat$AREA <- factor(sub_pat$AREA)
# levels(sub_pat$AREA) <- c("Aud_R","SupraG_L")

# P3: 1 = 0.0006 ,, 2 = 0.014 ,, 5 = 0.0011 ,, 7 = 0.004 ,, 9 = 0.03 ,, 11 = 0.006 ,, 12 = 0.02
# sub_pat = pat[pat$AREA =='1' | pat$AREA =='2' | 
#               pat$AREA =='5' | pat$AREA =='7'|
#               pat$AREA =='9' | pat$AREA =='11' |
#               pat$AREA =='12',]
# sub_pat$AREA <- factor(sub_pat$AREA)
# levels(sub_pat$AREA) <- c("Mot_R","Mot_L","STG_L","ITG_R","SupraG_L","MTG_R","SupraGParietal_L")


ggplot(sub_pat, aes(x=AREA, y=MEANPOW, fill=GROUP)) +
  geom_boxplot()+scale_fill_manual(values=c("#9999CC", "#66CC99"))+ylim(-3,3)


## -- Distracting sound

rm(list=ls())

ext1         <- "~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/"
# ext2         <- "dis1_200-250_4R.csv"
# ext2         <- "dis1_290-340_4R.csv"
ext2         <- "dis1_350-500_4R.csv"

pat          <- read.table(paste0(ext1,ext2),header=T,sep = ",")
pat$num_area <- factor(pat$num_area)

for (nline in 1:nrow(pat)){
  
  list_group = c('old','young')
  pat[nline,6] = list_group[length(grep('yc',as.character(pat[nline,1])))+1]
  
}

names(pat) <- c("SUB","CUE","MEANPOW","MAXABSPOW","AREA","GROUP")
pat$GROUP <- factor(pat$GROUP)

model.pat   <- lme4::lmer(MEANPOW ~ (GROUP+CUE+AREA)^3 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|AREA),details= TRUE)

# early P3
# 1 (0.013) 2 (0.011) 3 (0.013) 4 (0.011)
# sub_pat = pat[pat$AREA =='1' | pat$AREA =='2' |
#               pat$AREA =='3' | pat$AREA =='4',]
# 
# sub_pat$AREA <- factor(sub_pat$AREA)
# levels(sub_pat$AREA) <- c("Aud_R","Aud_L","Motor_R","IFG_L")

# late P3
# 1 (0.004) 3 (0.004) 4 (0.003) 5 (0.002) 
# sub_pat = pat[pat$AREA =='1' | pat$AREA =='3' |
#               pat$AREA =='4' | pat$AREA =='5',]
# 
# sub_pat$AREA <- factor(sub_pat$AREA)
# levels(sub_pat$AREA) <- c("TPole_L","Motor_L","IFG_L","SupraG_L")

# RON
# 3 (0.04) 4 (0.02) 5(0.02) 6 (0.01)

# sub_pat = pat[pat$AREA =='3' | pat$AREA =='4' |
#               pat$AREA =='5' | pat$AREA =='6',]
# 
# sub_pat$AREA <- factor(sub_pat$AREA)
# levels(sub_pat$AREA) <- c("STG_R","Mot_R","Mot_L","STG_L")


ggplot(sub_pat, aes(x=AREA, y=MEANPOW, fill=GROUP)) +
  geom_boxplot()+scale_fill_manual(values=c("#9999CC", "#66CC99"))+ylim(-3,3)

## -- Late Distracting sound

rm(list=ls())

ext1         <- "~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/"
# ext2         <- "dis2_200-250_4R.csv"
ext2         <- "dis2_290-340_4R.csv"

pat          <- read.table(paste0(ext1,ext2),header=T,sep = ",")
pat$num_area <- factor(pat$num_area)

for (nline in 1:nrow(pat)){
  
  list_group = c('old','young')
  pat[nline,6] = list_group[length(grep('yc',as.character(pat[nline,1])))+1]
  
}

names(pat) <- c("SUB","CUE","MEANPOW","MAXABSPOW","AREA","GROUP")
pat$GROUP <- factor(pat$GROUP)

model.pat   <- lme4::lmer(MEANPOW ~ (GROUP+CUE+AREA)^3 +(1|SUB), data =pat)
model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|AREA),details= TRUE)

# early p3
# 2 (0.04) 5 (0.04) 7 (0.03) 9 (0.02) 10 (0.006)
# sub_pat = pat[pat$AREA =='2' | pat$AREA =='5' |
#               pat$AREA =='7' | pat$AREA =='9' | pat$AREA =='10',]
# 
# sub_pat$AREA <- factor(sub_pat$AREA)
# levels(sub_pat$AREA) <- c("Aud_L","STG_R","Orb_R","Temp_R","IF_R")

# late P3
# 5 ( 0.0008)

sub_pat = pat[pat$AREA =='5',]

sub_pat$AREA <- factor(sub_pat$AREA)
levels(sub_pat$AREA) <- c("mot_R")

ggplot(sub_pat, aes(x=AREA, y=MEANPOW, fill=GROUP)) +
  geom_boxplot()+scale_fill_manual(values=c("#9999CC", "#66CC99"))+ylim(-3,3)
