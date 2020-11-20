install.packages('devtools',type='source')
library(devtools)
dev_mode()
install_github('ez','mike-lawrence')
library(ez)
library(car)

# PaperExtWAV.m600.p900.txt
# PaperExtConvol.m600.p900.txt
# PaperExtWAV.m600.p900.LatIndex.txt
# PaperExtConvol.m600.p900.LatIndex.txt	

pat=read.table("/Volumes/PAT_MEG/Fieldtripping/txt/PaperExtWAV.m600.p900.txt",header=T)
pat = pat[pat$TIME != 'm600' & pat$TIME != 'm400' & pat$TIME != 'm200' & pat$TIME != 'p400',] ;
pat = pat[pat$TIME != 'zero' & pat$TIME != 'p100' & pat$TIME != 'p200' & pat$TIME != 'p300' & pat$TIME != 'p500',]
pat = pat[pat$CHAN != 'maxPreR' & pat$CHAN != 'maxPreL' & pat$CHAN != 'maxSupL' & pat$CHAN != 'maxSupR',]

model.pat<- lme4::lmer(AVG ~ (COND+CHAN)^2 + (1|SUB), data =pat)
a <- Anova(model.pat,type=2)
print(a)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|CHAN))

#lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CHAN|FREQ))
#lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|FREQ))
#model.pat<- lme4::lmer(AVG ~ (COND*FREQ*CHAN) + (1|SUB), data =pat)
#lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|FREQ:CHAN))
#lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~COND|FREQ:PAIR))
#z = 0 ;
#freq = '11Hz';
#chan = 'maxSTL'
#x = pat[pat$COND == 'RCue' & pat$CHAN == chan & pat$FREQ == freq,6];
#y = pat[pat$COND == 'LCue' & pat$CHAN == chan & pat$FREQ == freq,6];
#z = pat[pat$COND == 'NCue' & pat$CHAN == chan & pat$FREQ == freq,6];
#boxplot(x,y,z,names = c('RCue','LCue','NCue'))
#title(paste(chan,'@',freq))