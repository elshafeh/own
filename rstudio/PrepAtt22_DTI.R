library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)
library(ggpubr)

rm(list=ls())

ext1  = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/dti/age_study/stat_by_tract/";
ext2  = "age_study_all_tracts.csv";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T,sep=",")
pat   = pat[,c(2:length(pat))]

pat$EDUCATION <- factor(pat$EDUCATION)
pat$MUSIC <- factor(pat$MUSIC)

model.pat <- lme4::lmer(mean_FA ~ (TRACT+GROUP)^2  + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2,test.statistic=c("F"))
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat,  pairwise~GROUP|TRACT),details= TRUE)

pat = pat[pat$TRACT=="Superior_cerebellar_peduncle_R" | 
            pat$TRACT=="Superior_cerebellar_peduncle_L" | 
            pat$TRACT=="Medial_lemniscus_R",]

ggplot(pat, aes(x=TRACT, y=mean_RD,fill=GROUP)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(0,0.0002))+
  scale_fill_manual(values=wes_palette(n=3, name="Royal1"))



for (gr in 1:length(list_tract)){ 
  
  sub_pat = pat[pat$TRACT==list_tract[gr],]
  
  boxplot(mean_FA~GROUP,data=sub_pat, main=list_tract[gr],ylim=c(0,0.1))
  
  #ggplot(sub_pat, aes(x=TRACT, y=max_FA,fill=GROUP)) + 
  #  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(0,1))+
  #  scale_fill_manual(values=wes_palette(n=3, name="Royal1"))
  
}




#list_tract <- as.character(unique(pat$TRACT))
#pat   = pat[pat$GROUP=="young",]

#res <- cor.test(sub_pat$mean_RD, sub_pat$arousal_effect, 
#                method = "pearson") # medianRT perCorrect cue_effect arousal_effect capture_effect

#if (res["p.value"] < 0.05){
#  print(gr)
#  print(list_tract[gr])
#  print(res["p.value"])
#  print(res["estimate"])

#gr = 38

#sub_pat = pat[pat$TRACT==list_tract[gr],]

#ggscatter(sub_pat, x = "mean_FA", y = "medianRT", 
#        add = "reg.line", conf.int = TRUE, 
#        cor.coef = TRUE, cor.method = "spearman",
#        xlab = list_tract[gr])
