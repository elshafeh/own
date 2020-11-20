install.packages('devtools',type='source')
library(devtools)
dev_mode()
#install_github('ez','mike-lawrence')
library(ez)

# PaperExtWAV.m600.p900.txt
# PaperExtConvol.m600.p900.txt
# PaperExtWAV.m600.p900.LatIndex.txt
# PaperExtConvol.m600.p900.LatIndex.txt	

pat=read.table("/Volumes/PAT_MEG/Fieldtripping/txt/PaperExtWAV.m600.p900.txt",header=T)

model.pat<- lme4::lmer(pat$AVG ~ COND*CHAN*FREQ*TIME + (1|SUB), data =pat)

model.pat<- lme4::lmer(pat$AVG ~ CUE*DIS + (1|SUB), data =pat)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~DIS|CUE))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE|DIS))
