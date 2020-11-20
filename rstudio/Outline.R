library(ez)
library(car)
library(dae)
library(nlme)
library(effects)
library(ggplot2)
library(psych)
library(interplot)
library(plyr)

rm(list=ls())
ext1  = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/";
ext2  = "BehavioralSummaryUninformativeDivided.txt";
fname = paste0(ext1,ext2, collapse = NULL);
all_pat   = read.table(fname,header=T)

#all_pat   <- all_pat[all_pat$DIS=="D0" & all_pat$CORR==1 & all_pat$ERROR==0,]
#all_pat   <- all_pat[all_pat$RT > 199,]

all_pat$XP <- factor(all_pat$XP) ; all_pat$REP <- factor(all_pat$REP) ; 
all_pat$CORR <- factor(all_pat$CORR) ; all_pat$ERROR <- factor(all_pat$ERROR) 
all_pat$TAR_PITCH <- factor(all_pat$TAR_PITCH)

#ggplot(all_pat, aes(x=SUB, y=RT, color=GROUP)) + geom_boxplot()

list_grp <- as.character(unique(all_pat$GROUP))
list_cue <- as.character(unique(all_pat$CUE))

pat_concat <- data.frame(SUB=character(), GROUP=character(),CUE=character(), DIS =character(),medianRT = numeric(),stringsAsFactors=TRUE)

for (x in 1:length(list_grp)){
  
  pat <- all_pat[all_pat$GROUP == list_grp[x],]
  list_suj <- as.character(unique(pat$SUB))
  
  for (h in 1:length(list_suj)){
    sub_pat <- pat[pat$SUB == list_suj[h],] 
    # for (y in 1:length(list_cue)){
    
    perc_pat <- sub_pat[sub_pat$CUE == list_cue[y] & sub_pat$DIS=="D0" & sub_pat$CORR==1 & sub_pat$ERROR==0,13]
    tot_pat <- sub_pat[sub_pat$CUE == list_cue[y] & sub_pat$DIS=="D0",13]
    percent <- (length(perc_pat)/length(tot_pat))*100
    
    # median_RT <- median(sub_pat[sub_pat$CUE == list_cue[y],13])
    
    # if (!is.na(median_RT)){
    
    # if (list_cue[y] == "NCue"){new_cue="Uninformative"}
    # else {new_cue="Informative"}
    
    bloc <- cbind(list_suj[h],list_grp[x],percent)
    pat_concat<-rbind(pat_concat,bloc)
    
    # }
    # }
  }
}

pat <- pat_concat
rm(list=setdiff(ls(), "pat"))
names(pat) <- c("SUB","GROUP","CUE", "percent")

pat$percent <- as.numeric(levels(pat$percent))[pat$percent]
pat$SUB <- factor(pat$SUB)
pat$GROUP <- factor(pat$GROUP)
pat$CUE <- factor(pat$CUE)

pat_yc <- pat[pat$GROUP == "yc",]
pat_oc <- pat[pat$GROUP == "oc",]