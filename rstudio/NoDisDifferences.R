library(car)
library(dae)
library(nlme)
library(effects)
library(ggplot2)
library(psych)
library(interplot)
library(plyr)
library(devtools)
library(ez)

rm(list=ls())
ext1  = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/";
ext2  = "BehavioralSummaryUninformativeDivided.txt";
fname = paste0(ext1,ext2, collapse = NULL);
all_pat   = read.table(fname,header=T)

all_pat$XP <- factor(all_pat$XP) ; all_pat$REP <- factor(all_pat$REP) ; 
all_pat$CORR <- factor(all_pat$CORR) ; all_pat$ERROR <- factor(all_pat$ERROR) 
all_pat$TAR_PITCH <- factor(all_pat$TAR_PITCH)

#all_pat   <- all_pat[all_pat$DIS=="D0" & all_pat$CORR==1 & all_pat$ERROR==0,]
#all_pat   <- all_pat[all_pat$RT > 199,]
#ggplot(all_pat, aes(x=SUB, y=RT, color=GROUP)) + geom_boxplot()

list_grp <- as.character(unique(all_pat$GROUP))
list_cue <- as.character(unique(all_pat$CUE))
list_dis <- as.character(unique(all_pat$DIS))

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         CUE=character(), DIS =character(),
                         medianRT = numeric(),stringsAsFactors=TRUE)

for (x in 1:length(list_grp)){
  
  pat <- all_pat[all_pat$GROUP == list_grp[x],]
  list_suj <- as.character(unique(pat$SUB))
  
  for (h in 1:length(list_suj)){
    
    sub_pat <- pat[pat$SUB == list_suj[h],] 
    
    for (y in 1:length(list_cue)){
      
      for (z in 1:length(list_dis)){
        
        
        perc_pat <- sub_pat[sub_pat$CUE == list_cue[y] & sub_pat$DIS == list_dis[z]
                            & sub_pat$CORR==1 & sub_pat$ERROR==0,13]
        
        tot_pat <- sub_pat[sub_pat$CUE == list_cue[y] & sub_pat$DIS==list_dis[z],13]
        
        percent <- (length(perc_pat)/length(tot_pat))*100
        
        median_RT <- median(sub_pat[sub_pat$CUE == list_cue[y] & sub_pat$DIS==list_dis[z] 
                                    & sub_pat$CORR==1 & sub_pat$ERROR==0 ,13])
        
        # if (!is.na(median_RT)){
        if (list_cue[y] == "NCue"){new_cue="Uninformative"}
        else {new_cue="Informative"}
        
        bloc <- cbind(list_suj[h],list_grp[x],list_cue[y],list_dis[z],median_RT,percent)
        pat_concat<-rbind(pat_concat,bloc)
        
      }
    }
  }
}

pat <- pat_concat
rm(list=setdiff(ls(), "pat"))
names(pat) <- c("SUB","GROUP","CUE", "DIS","medianRT","percent")

pat$medianRT <- as.numeric(levels(pat$medianRT))[pat$medianRT]
pat$percent <- as.numeric(levels(pat$percent))[pat$percent]
pat$SUB <- factor(pat$SUB)
pat$GROUP <- factor(pat$GROUP)
pat$CUE <- factor(pat$CUE)
pat$DIS <- factor(pat$DIS)

#pat <- pat[pat$DIS=="D0",]

theme = theme_set(theme_minimal())
theme = theme_update(legend.position="right", 
                     legend.title=element_blank(), 
                     panel.grid.major.x=element_blank(),
                     text = element_text(size=16))

ggplot(pat, aes(x=GROUP, y=medianRT,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(300, 1000))

# Shapiro-Wilk normality test for OC
with(pat, shapiro.test(medianRT[GROUP == "yc"]))
# Shapiro-Wilk normality test for YC
with(pat, shapiro.test(medianRT[GROUP == "oc"]))

# We???ll use F-test to test for homogeneity in variances.
#This can be performed with the function var.test() as follow:
res.ftest <- var.test(medianRT ~ GROUP, data = pat)
print(res.ftest)

#Performs Bartlett's test of the null that the 
#variances in each of the groups (samples) are the same.
brt <- bartlett.test(medianRT ~ GROUP, data = pat)
print(brt)

ggplot(pat[pat$DIS=="D0",], aes(x=GROUP, y=percent, fill=CUE)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(80, 100))

ggplot(pat[pat$DIS=="D0",], aes(x=GROUP, y=medianRT, fill=CUE)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(350, 950))

ggplot(pat, aes(x=SUB, y=percent, color=GROUP)) + geom_boxplot()
t.test(pat_yc$percent,pat_oc$percent)

pat_yc <- pat[pat$GROUP=="yc",c(1,3,4,5,6)]
pat_yc$SUB <- factor(pat_yc$SUB)

a <- ezANOVA(pat_yc,dv=.(medianRT),wid = .(SUB),within = .(CUE,DIS),detailed=T)
print(a)
pat_oc <- pat[pat$GROUP=="oc",c(1,3,4,5,6)]
pat_oc$SUB <- factor(pat_oc$SUB)
b <- ezANOVA(pat_oc,dv=.(medianRT),wid = .(SUB),within = .(CUE,DIS),detailed=T)
print(b)

c <- ezANOVA(pat,dv=.(medianRT),wid = .(SUB),within = .(CUE,DIS),between = (GROUP),detailed=T)
print(c)