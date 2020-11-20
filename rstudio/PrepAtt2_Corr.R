library(ez)
library(car)

pat = read.table("/Volumes/PAT_MEG/Fieldtripping/txt/200ms_CorrVirtual4R.txt",header=T)
pat = pat[pat$TIME == '900ms',]

model.pat<- lme4::lmer(CORR ~ COND*CHAN*FREQ + (1|SUB), data =pat)
a <-Anova(model.pat,type=2)

chn = 'maxSupR'

rcue = pat[pat$COND == 'RCUe' & pat$CHAN == chn,6]
lcue = pat[pat$COND == 'LCue' & pat$CHAN == chn,6]
ncue = pat[pat$COND == 'NCue' & pat$CHAN == chn,6]

boxplot(rcue,lcue,ncue, names=c("rcue", "lcue", "ncue"),
        col=c("blue","red","yellow"), 
        xlab=chn, ylab='Correlation',font.lab = 1,ylim=c(-0.4, 0.4))

lsmeans::cld(lsmeans::lsmeans(model.pat, "COND"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "CHAN"))

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|CHAN))