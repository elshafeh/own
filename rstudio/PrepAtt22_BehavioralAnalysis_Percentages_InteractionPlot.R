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
    
    for (cue in 1:4){
      for (dis in 1:3){
        
        if (cue>2){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-2 & pat$DIS==dis-1,]}
        if (cue==1){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$TAR%%2 != 0 & pat$DIS==dis-1,]}
        if (cue==2){new_cue=sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==0 & pat$TAR%%2 == 0 &pat$DIS==dis-1,]}
        
        suj <- paste0(names_group[gr],sb)
        
        n_incorrect <- lengths(sub_pat[sub_pat$CORR==-1,])[1]
        n_miss <- lengths(sub_pat[sub_pat$ERROR==1,])[1]
        n_fa <- lengths(sub_pat[sub_pat$ERROR==3,])[1]
        n_tot <- lengths(sub_pat)[1]
        
        p_incorrect <- (n_incorrect/n_tot)*100
        p_miss <- (n_miss/n_tot)*100
        p_fa <- (n_fa/n_tot)*100
        
        cue_names = c('NLCue','NRCue','LCue','RCue')
        dis_names = c('D0','D1','D2')
        
        medianRT = median(sub_pat[sub_pat$CORR==1,11])
        
        bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],p_incorrect,p_miss,p_fa,medianRT)
        
        pat_concat<-rbind(pat_concat,bloc)
        
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))

names(pat_concat) <- c("SUB","GROUP","CUE","DIS","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT")

pat_concat<- pat_concat[pat_concat$GROUP=="young",]

pd <- position_dodge(.2)

ggplot(pat_concat, aes(x=DIS, y=MedianRT, colour=CUE, group=CUE, 
                   shape=CUE)) + 
  stat_summary(fun.data = "mean_se", geom="errorbar",position=pd) +
  stat_summary(fun.y="mean", geom="line",position=pd) + 
  stat_summary(fun.y="mean", geom="point", size=8,position=pd)  +
  
  scale_x_discrete(breaks=c("0", "1", "2"), labels=c("T0", "T1", "T2"))+
  coord_cartesian(ylim=c(2, 7)) + 
  scale_y_continuous(breaks=seq(2, 6, 2)) +
  scale_color_manual(values=c("gray30", "gray50","gray70"),name  ="Gruppe",
                     breaks=c("baseline", "negative", "neutral"),
                     labels=c("Baseline", "Attend-negative", "Attend-neutral")) +
  scale_shape_discrete(name  ="Gruppe",
                       breaks=c("baseline", "negative", "neutral"),
                       labels=c("Baseline", "Attend-negative", "Attend-neutral")) +
  theme(
    panel.grid.major.y = element_line(colour = "gray80", size = NULL, linetype = NULL,  # horizontale Linien
                                      lineend = NULL)
    ,panel.grid.minor.y = element_line(colour = "gray90", size = NULL, linetype = NULL,
                                       lineend = NULL)
    ,panel.grid.major.x = element_blank()           # vertikale Linien
    ,panel.grid.minor.x = element_blank()
    ,legend.background = element_rect(fill = "white", colour = "white") # Legende 
    ,legend.key = element_rect(fill = "white", colour = "white")
    ,panel.background = element_rect(fill = "white", colour = "white", size = NULL, # Panel Hintergrund
                                     linetype = NULL)
    ,axis.line = element_line(colour = "black", size=.5)
    ,axis.ticks.x = element_line(colour = "black", size=.5)
    ,axis.ticks.y = element_line(colour = "black", size=.5)
    ,axis.ticks.length =  unit(0.5, "cm")
    ,axis.ticks.margin =  unit(.3, "cm")
    ,axis.title.x = element_text(family = NULL, face = "bold", size = 11,vjust=0.1)
    ,axis.title.y = element_text(family = NULL, face = "bold", size = 11,vjust=0.1)
    ,axis.text=element_text(colour="black")
    ,legend.title = element_text(family = NULL, face = "plain", size = 11)
    ,legend.text = element_text(family = NULL, face = "plain", size = 9)
  ) +
  xlab("Messzeitpunkt")+
  ylab("State-KA (M)") 