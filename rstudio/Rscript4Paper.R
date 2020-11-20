#-------------------#
#for behavioral data#
#-------------------#

library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)

rm(list=ls())
pat=read.table("/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/txt/PrepAtt2.new.medianRT.txt",header=T)
pat = pat[pat$DIS == 'D0' ,]

for (n in 1:lengths(pat)[2]){
  
  if (as.character(pat[n,2]== "NL")) {
    pat[n,5] = "NCue"
  } else if (as.character(pat[n,2]== "NR")) {
    pat[n,5] = "NCue"
  } else if (as.character(pat[n,2]== "L")) {
    pat[n,5] = "LCue"
  } else
    pat[n,5] = "RCue"
}

pat <- pat[c(1,3,4,5)]
names(pat) <- c("SUB","DIS","MedianRT","CUE_CAT")

pat$CUE_CAT <- factor(pat$CUE_CAT)
pat$DIS <- factor(pat$DIS)


ggplot(pat, aes(x=CUE_CAT, y=MedianRT,fill=MedianRT)) + 
  geom_boxplot()+ coord_cartesian(xlim=NULL,ylim=c(250, 1000))+
  scale_fill_manual(values=c("#E69F00", "#56B4E9"))+
  labs(y="medianRT",x="Cue")

b <- ezANOVA(pat,dv=.(MedianRT),wid = .(SUB),within = .(CUE_CAT),detailed=T)

cue_effect<-pairwise.t.test(pat$MedianRT,pat$CUE_CAT,paired=TRUE,p.adjust.method="fdr")

#model.pat <- lme4::lmer(MedianRT ~ (CUE_CAT) + (1|SUB), data =pat)
#a         <-Anova(model.pat,type=2,test.statistic = c("F"))
#print(a)
#x <- lsmeans::cld(lsmeans::lsmeans(model.pat, "CUE_CAT"),details= TRUE)

---------
## IAF ##
---------
library(ez)
library(car)
rm(list=ls())
ext1  = "/Users/heshamelshafei/Google Drive/PhD/Fieldtripping/txt/";
ext2  = "BigCovariance.HemiByModByTimeByFreq.IAF4Paper.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)
pat = pat[pat$MODALITY != "Mot",]

model.pat <- lme4::lmer(VAL ~ (MODALITY*HEMI) + (1|SUB), data =pat)
b <- ezANOVA(pat,dv=.(VAL),wid = .(SUB),within = .(MODALITY,HEMI),detailed=T)
a         <-Anova(model.pat,type=3,test.statistic=c("F"))
print(a)

x <- lsmeans::cld(lsmeans::lsmeans(model.pat, "MODALITY"),details= TRUE)



# #-------------------------------------#
# # ! NEW!virtual electrode : Cue effect#
# #-------------------------------------#
# library(ez)
# library(car)
# rm(list=ls())
# ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
# ext2  = "BigCovariance.HemiByModByTimeByFreq.txt";
# fname = paste0(ext1,ext2, collapse = NULL);
# pat   = read.table(fname,header=T);
# pat   = pat[pat$TIME != "700ms",]
# pat   = pat[pat$TIME != "10500ms",]
# 
# model.pat <- lme4::lmer(POW ~ (COND+MODALITY+HEMI+FREQ+TIME)^4 + (1|SUB), data =pat)
# a         <-Anova(model.pat,type=2)
# print(a)
# 
# #pat =  pat[pat$FREQ != "7Hz",];pat =  pat[pat$FREQ != "8Hz",]
# #pat =  pat[pat$FREQ != "10Hz",];pat =  pat[pat$FREQ != "11Hz",]
# #pat =  pat[pat$FREQ != "12Hz",];pat =  pat[pat$FREQ != "14Hz",]
# #pat =  pat[pat$FREQ != "15Hz",]
# 
# #nw_model.pat <- lme4::lmer(POW ~ (COND+MODALITY+HEMI+FREQ+TIME)^4 + (1|SUB), data =pat)
# #nw_a         <-Anova(nw_model.pat,type=2)
# #print(nw_a)
# 
# lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|CHAN))
# 
# sub_pat = pat[pat$HEMI == "R",]
# model.pat <- lme4::lmer(POW ~ (COND*MODALITY*FREQ) + (1|SUB), data =sub_pat)
# sb_a         <-Anova(model.pat,type=2)
# print(sb_a)
# lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|MODALITY))
# 
# #---------------------------------------------#
# # ! NEW!virtual electrode : Correlation effect#
# #---------------------------------------------#
# library(ez)
# library(car)
# rm(list=ls())
# ext1  = "/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/";
# ext2  = "BigCovariance.HemiByModByTimeByFreq.Correlation.txt";
# fname = paste0(ext1,ext2, collapse = NULL);
# pat   = read.table(fname,header=T)
# pat   = pat[pat$TIME != "700ms",]
# pat   = pat[pat$TIME != "1050ms",]
# model.pat <- lme4::lmer(CORR ~ (COND+MODALITY+HEMI+FREQ+TIME)^4 + (1|SUB), data =pat)
# a         <-Anova(model.pat,type=2)
# print(a)