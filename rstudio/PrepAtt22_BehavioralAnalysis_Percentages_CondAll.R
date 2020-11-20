library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)

rm(list=ls())
names_group=c("old","young","patient","control")

fname = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R.csv"
behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=numeric(), p_miss =numeric(),
                         p_falseAlarm = numeric(),stringsAsFactors=TRUE)

for (gr in 1:length(list_grp)){
  
  pat <- behav_summary[behav_summary$idx_group == list_grp[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    sub_pat <- pat[pat$sub_idx == list_suj[sb],]
    suj <- paste0(names_group[gr],sb)
    
    n_incorrect <- lengths(sub_pat[sub_pat$CORR==-1,])[1]
    n_miss <- lengths(sub_pat[sub_pat$ERROR==1,])[1]
    n_fa <- lengths(sub_pat[sub_pat$ERROR==3,])[1]
    n_tot <- lengths(sub_pat)[1]
    
    p_incorrect <- (n_incorrect/n_tot)*100
    p_miss <- (n_miss/n_tot)*100
    p_fa <- (n_fa/n_tot)*100
    
    bloc <- cbind(suj,names_group[gr],p_incorrect,p_miss,p_fa)
    pat_concat<-rbind(pat_concat,bloc)
    
  }
}

names(pat_concat) <- c("SUB","GROUP","PerIncorrect", "PerMiss","PerFlaseAlarm")

pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]

ggplot(pat_concat, aes(x=GROUP, y=PerIncorrect,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(0, 20))

ggplot(pat_concat, aes(x=GROUP, y=PerMiss,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(0, 20))

ggplot(pat_concat, aes(x=GROUP, y=PerFlaseAlarm,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(0, 20))


t_age1 <- t.test(pat_concat[pat_concat$GROUP=="old",3],pat_concat[pat_concat$GROUP=="young",3])
t_age2 <- t.test(pat_concat[pat_concat$GROUP=="old",4],pat_concat[pat_concat$GROUP=="young",4])
t_age3 <- t.test(pat_concat[pat_concat$GROUP=="old",5],pat_concat[pat_concat$GROUP=="young",5])

t_avc1 <- t.test(pat_concat[pat_concat$GROUP=="patient",3],pat_concat[pat_concat$GROUP=="control",3])
t_avc2 <- t.test(pat_concat[pat_concat$GROUP=="patient",4],pat_concat[pat_concat$GROUP=="control",4])
t_avc3 <- t.test(pat_concat[pat_concat$GROUP=="patient",5],pat_concat[pat_concat$GROUP=="control",5])