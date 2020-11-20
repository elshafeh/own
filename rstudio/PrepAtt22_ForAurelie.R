library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
fname =  "/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/PrepAtt22_behav_table4R_withTukey.csv"

behav_summary <- read.table(fname,header=T, sep=";")

list_grp <- unique(behav_summary$idx_group)
names_group=c("old","young","patients","control")

pat_concat <- data.frame(SUB=character(), GROUP=character(),
                         p_incorrect=numeric(), p_miss =numeric(),
                         p_falseAlarm = numeric(),stringsAsFactors=TRUE)

for (gr in 1:length(list_grp)){
  
  pat <- behav_summary[behav_summary$idx_group == list_grp[gr],]
  list_suj <- unique(pat$sub_idx)
  
  for (sb in 1:length(list_suj)){
    
    for (cue in 1:3){
      for (dis in 1:3){
        #for (tar in 1:4){
        
        sub_pat <- pat[pat$sub_idx == list_suj[sb] & pat$CUE==cue-1 &pat$DIS==dis-1,]
        
        suj <- paste0(names_group[gr],sb)
        
        n_incorrect <- lengths(sub_pat[sub_pat$CORR==-1,])[1]
        n_miss <- lengths(sub_pat[sub_pat$ERROR==1,])[1]
        n_fa <- lengths(sub_pat[sub_pat$ERROR==3,])[1]
        n_tot <- lengths(sub_pat)[1]
        
        p_incorrect <- (n_incorrect/n_tot)*100
        p_miss <- (n_miss/n_tot)*100
        p_fa <- (n_fa/n_tot)*100
        
        #cue_names = c('Inf','Unf')
        
        cue_names = c('NCue','LCue','RCue')
        dis_names = c('D0','D1','D2')
        tar_names = c('Left','Right','Left','Right')
        
        if (cue==1) {
          cue_group='UnInformative'
        } else {
          cue_group='Informative'
        }
      
        
        medianRT = median(sub_pat[sub_pat$CORR>0,11])
        medianRT_tukey = median(sub_pat[sub_pat$CORR==1,11])
        
        #bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],tar_names[tar],cue_group,p_incorrect,p_miss,p_fa,medianRT,medianRT_tukey)
        bloc <- cbind(suj,names_group[gr],cue_names[cue],dis_names[dis],cue_group,p_incorrect,p_miss,p_fa,medianRT,medianRT_tukey)
        
        pat_concat<-rbind(pat_concat,bloc)
        
        #}
      }
    }
  }
}

rm(list=setdiff(ls(), "pat_concat"))
#names(pat_concat) <- c("SUB","GROUP","CUE","DIS","CUE_CAT","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT","MedianRT_tukey")
names(pat_concat) <- c("SUB","GROUP","CUE","DIS","CUE_CAT","PerIncorrect", "PerMiss","PerFlaseAlarm","MedianRT","MedianRT_tukey")

pat_concat$PerIncorrect <- as.numeric(levels(pat_concat$PerIncorrect))[pat_concat$PerIncorrect]
pat_concat$PerMiss <- as.numeric(levels(pat_concat$PerMiss))[pat_concat$PerMiss]
pat_concat$PerFlaseAlarm <- as.numeric(levels(pat_concat$PerFlaseAlarm))[pat_concat$PerFlaseAlarm]
pat_concat$MedianRT <- as.numeric(levels(pat_concat$MedianRT))[pat_concat$MedianRT]
pat_concat$MedianRT_tukey <- as.numeric(levels(pat_concat$MedianRT_tukey))[pat_concat$MedianRT_tukey]

pat_concat <- pat_concat[complete.cases(pat_concat), ]
pat_concat <- pat_concat[!is.na(pat_concat$MedianRT),]

pat_group <- pat_concat[pat_concat$GROUP=="old" | pat_concat$GROUP=="young",]
pat_group$SUB <- factor(pat_group$SUB)
pat_group$GROUP <- factor(pat_group$GROUP)


#model.pat   <- lme4::lmer(MedianRT ~ (GROUP+CUE_CAT+DIS)^2 + (1|SUB), data =pat_group)
#model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
#print(model_anova)
#lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|DIS),details= TRUE)


group_anova <- ezANOVA(pat_group,dv=.(PerIncorrect),wid = .(SUB),within = .(CUE_CAT,DIS),between = (GROUP),detailed=T)

print(group_anova)

tgc <- summarySE(pat_group, measurevar="MedianRT", groupvars=c("CUE_CAT","DIS","GROUP"))

pd <- position_dodge(0.05)

interaction.ABC.plot(MedianRT, x.factor=DIS,
                     groups.factor=CUE_CAT, trace.factor=GROUP,
                     data=pat_group, c,ggplotFunc=list(labs(x="Distractor Delay",y="Median Reaction Time"),
                                                        ggtitle(""),ylim(450,650),geom_errorbar(data=tgc,aes(ymax=MedianRT+se, ymin=MedianRT-se),width=0.2,position = pd)))



######################################################3





#ggplot(pat_group, aes(x=CUE_CAT, y=MedianRT,fill=MedianRT)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(250, 1000))+
  scale_fill_manual(values=c("#E69F00", "#56B4E9"))+
  labs(y="medianRT",x="Cue")

pat_group <- pat_concat[pat_concat$GROUP=="young",]
pat_group$SUB <- factor(pat_group$SUB)
pat_group$GROUP <- factor(pat_group$GROUP)

pat_group = pat_group[pat_group$DIS=='D0',]

ggplot(pat_group, aes(x=CUE_CAT, y=MedianRT,fill=MedianRT)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(250, 1000))+
  scale_fill_manual(values=c("#E69F00", "#56B4E9"))+
  labs(y="medianRT",x="Cue")

#pat_group <- pat_group[!is.na(pat_group$MedianRT),]
#pat_yc <- pat_concat[pat_concat$GROUP=="young",]
#pat_yc$SUB <- factor(pat_group$SUB)
#pat_yc$GROUP <- factor(pat_group$GROUP)



pd <- position_dodge(0.05)

legend_title <- "OMG My Title"



svg(filename="/Users/heshamelshafei/Desktop/pour_aurelie/Std_SVG.svg", 
    width=5, 
    height=4, 
    pointsize=12)

dev.off()

#pat_group[pat_group$DIS=='D0',]

ggplot(pat_group, aes(x=GROUP, y=MedianRT, fill=DIS)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(300, 1000))


#interaction.plot(pat_group$DIS, pat_group$CUE_CAT,
#                 pat_group$PerIncorrect, fun= mean,
#                 col=c(4,2,5),lwd = 4, lty = 1, legend = TRUE)



par(mfrow=c(4,4))

list_suj <- as.character(unique(pat_group$SUB))

for (sb in 1:length(list_suj)){
  
  pat_sub = pat_group[pat_group$SUB==list_suj[sb],]
  interaction.plot(pat_sub$DIS, pat_sub$CUE_CAT,pat_sub$MedianRT, ylim=c(450,1100),fun= mean,col=c(4,2,5),lwd = 4, lty = 1, legend = TRUE,xlab ='CUE',ylab=paste('Median',list_suj[sb]))
  
}


### 

pat_group <- pat_concat

list_group <- as.character(unique(pat_group$GROUP))
spec_test  <- data.frame(SUB=character(), GROUP=character())

for (gr in 1:length(list_group)){
  
  list_suj <- pat_group[pat_group$GROUP==list_group[gr],]
  list_suj <- as.character(unique(list_suj$SUB))
  
  for (sb in 1:length(list_suj)){
    
    suj  = list_suj[sb]
    vcue = mean(pat_group[pat_group$GROUP==list_group[gr] & pat_group$SUB==suj & pat_group$DIS=='D0' & pat_group$CUE_CAT=='Informative',9])
    ncue = pat_group[pat_group$GROUP==list_group[gr] & pat_group$SUB==suj & pat_group$DIS=='D0' & pat_group$CUE_CAT=='UnInformative',9]
    
    
    D0= mean(pat_group[pat_group$GROUP==list_group[gr] & pat_group$SUB==suj & pat_group$DIS=='D0',9])
    D1= mean(pat_group[pat_group$GROUP==list_group[gr] & pat_group$SUB==suj & pat_group$DIS=='D1',9])
    D2= mean(pat_group[pat_group$GROUP==list_group[gr] & pat_group$SUB==suj & pat_group$DIS=='D2',9])
    
    bloc <- cbind(suj,list_group[gr],vcue-ncue,D0-D1,D2-D1,D2-D0)
    spec_test<-rbind(spec_test,bloc)
    
  }
}

names(spec_test) <- c("SUB","GROUP","vcueMINUSncue","D0MINUSD1","D1MINUSD2","D0MINUSD2")
spec_test$vcueMINUSncue <- as.numeric(levels(spec_test$vcueMINUSncue))[spec_test$vcueMINUSncue]
spec_test$D0MINUSD1 <- as.numeric(levels(spec_test$D0MINUSD1))[spec_test$D0MINUSD1]
spec_test$D1MINUSD2 <- as.numeric(levels(spec_test$D1MINUSD2))[spec_test$D1MINUSD2]
spec_test$D0MINUSD2 <- as.numeric(levels(spec_test$D0MINUSD2))[spec_test$D0MINUSD2]

spec_test$SUB <- factor(spec_test$SUB)
spec_test$GROUP <- factor(spec_test$GROUP)

i_test = 5
res <- t.test(spec_test[spec_test$GROUP=='old',i_test], spec_test[spec_test$GROUP=='young',i_test])
res

ggplot(spec_test, aes(x=GROUP, y=D1MINUSD2,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(-100, 300))+
  scale_fill_manual(values=c("#E69F00", "#56B4E9"))+
  labs(y="D0 minus D1",x="Group")

ggplot(spec_test, aes(x=GROUP, y=D1MINUSD2,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(-20, 200))+
  scale_fill_manual(values=c("#E69F00", "#56B4E9"))+
  labs(y="D2 minus D1",x="Group")


group_anova <- ezANOVA(pat_group,dv=.(PerIncorrect),wid = .(SUB),within = .(CUE_CAT,DIS),between = (GROUP),detailed=T)
print(group_anova)

ggplot(pat_group, aes(x=DIS, y=PerIncorrect,fill=DIS)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(0,25))+
  scale_fill_manual(values=wes_palette(n=3, name="Royal1"))+
  labs(y="Percentage Incorrect",x="Distractor")

dis_effect<-pairwise.t.test(pat_group$PerIncorrect,pat_group$DIS,paired=TRUE,p.adjust.method="fdr")
print(dis_effect)
