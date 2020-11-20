library(ez)
library(car)

pat = read.table("/Volumes/PAT_MEG/Fieldtripping/txt/plv4R_Fischer.txt",header=T)

#pat = pat[pat$PAIR != 'maxLO.maxR' ,]
#pat = pat[pat$PAIR != 'maxHR.maxSTR'  , ]
#pat = pat[pat$PAIR != 'maxHL.maxHR' , ]
#pat = pat[pat$PAIR != 'maxHL.maxSTL' , ]
#pat = pat[pat$PAIR != 'maxHL.maxSTR'  , ]
#pat = pat[pat$PAIR != 'maxHR.maxSTL' , ]
#pat = pat[pat$PAIR != 'maxSTL.maxSTR' , ]

pat = pat[pat$PAIR == 'maxSTR.rpifO' | pat$PAIR == 'maxSTR.raifG'|pat$PAIR == 'maxSTR.rpiF'|pat$PAIR == 'maxHR.rpifO'
          |pat$PAIR == 'maxHR.raifG' | pat$PAIR == 'maxHR.rpiF' | pat$PAIR == 'maxRO.maxHR' | pat$PAIR == 'maxRO.maxSTR',]

pat = pat[pat$PAIR == 'maxRO.maxHR' | pat$PAIR == 'maxRO.maxSTR', ]

pat = pat[pat$PAIR == 'maxSTR.rpifO' | pat$PAIR == 'maxSTR.raifG'|pat$PAIR == 'maxSTR.rpiF'|pat$PAIR == 'maxHR.rpifO'
          |pat$PAIR == 'maxHR.raifG' |pat$PAIR == 'maxHR.rpiF'
           |pat$PAIR == 'maxRO.maxHR' | pat$PAIR == 'maxRO.maxSTR'|
            pat$PAIR == 'maxLO.maxHR' | pat$PAIR == 'maxLO.maxSTR', ]

#pat = pat[pat$PAIR == 'maxSTR.rpiF', ]
#pat = pat[pat$PAIR == 'maxSTR.rpiF'| pat$PAIR == 'maxHR.rpifO', ]

model.pat <- lme4::lmer(PLV ~ (COND+FREQ+PAIR)^2 + (1|SUB), data =pat)
a         <- Anova(model.pat,type=2)
print(a)

lsmeans::lsm.options(pbkrtest.limit = 6384)
lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~COND|PAIR))
lsmeans::cld(lsmeans::lsmeans(model.pat,"FREQ"))