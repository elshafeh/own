library(ez)
library(car)

pat=read.table("/Volumes/PAT_MEG/Fieldtripping/txt/mean_IAF4R.txt",header=T)

model.pat<- lme4::lmer(IAF ~ TIME*ROI + (1|SUB), data =pat)
Anova(model.pat,type=2)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~ROI|TIME))
lsmeans::cld(lsmeans::lsmeans(model.pat, "TIME"))

time_bsl = pat[pat$TIME == 'bsl',4];
time_ear = pat[pat$TIME == 'early',4];
time_lat = pat[pat$TIME == 'late',4];
time_pos = pat[pat$TIME == 'post',4];

boxplot(time_bsl,time_ear,time_lat,time_pos, names=c("Bsl", "Early", "Late","Post"),
        col=c("blue","red","green","yellow"), 
        notch=TRUE,xlab="Time Windows", ylab="IAF",font.lab = 1,ylim=c(7, 15))

tobox1 = pat[pat$TIME == 'late' & pat$ROI == 'Vis',4]
tobox2 = pat[pat$TIME == 'late' & pat$ROI == 'Aud',4]
tobox3 = pat[pat$TIME == 'late' & pat$ROI == 'Mot',4]

tobox4 = pat[pat$TIME == 'early' & pat$ROI == 'Vis',4]
tobox5 = pat[pat$TIME == 'early' & pat$ROI == 'Aud',4]
tobox6 = pat[pat$TIME == 'early' & pat$ROI == 'Mot',4]

boxplot(tobox4,tobox5,tobox6, names=c("Vis", "Aud", "Mot"),
        col=c("blue","red","yellow"), 
        xlab="ROIs", ylab="IAF [200 - 600ms]",font.lab = 1 ,ylim=c(7, 15))

boxplot(tobox1,tobox2,tobox3, names=c("Vis", "Aud", "Mot"),
        col=c("blue","red","yellow"), 
        xlab="ROIs", ylab="IAF [600 - 1000 ms]",font.lab = 1,ylim=c(7, 15))