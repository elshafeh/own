library(ez)
library(car)

#pat = read.table("/Users/heshamelshafei/Documents/MATLAB/Fieldtripping/txt/ActivityIndexAll.sepOcc.sepAud.0taper.txt",header=T)

rm(list=ls())
pat = read.table("/Volumes/PAT_MEG/Fieldtripping/txt/AvgCorrVirtual4R4Paperr.txt",header=T)
model.pat <- lme4::lmer(CORR ~ (COND+CHAN+FREQ)^2 + (1|SUB), data =pat)
a         <-Anova(model.pat,type=2);print(a)
lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~COND|CHAN))

lsmeans::cld(lsmeans::lsmeans(model.pat, "COND"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "CHAN"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "FREQ"))
lsmeans::cld(lsmeans::lsmeans(model.pat, "TIME"))

#pat = pat[pat$CHAN != 'maxPreL' ,];pat = pat[pat$CHAN != 'maxPreR' ,];pat = pat[pat$CHAN != 'maxSupL' ,];pat = pat[pat$CHAN != 'maxSupR' ,]

#pat = pat[pat$CHAN != 'Rocc.STG' ,];pat = pat[pat$CHAN != 'Locc.STG' ,];pat = pat[pat$CHAN != 'RLocc.STG' ,]
#pat = pat[pat$CHAN != 'Rocc.Raud' ,];pat = pat[pat$CHAN != 'Locc.Raud' ,];pat = pat[pat$CHAN != 'RLocc.Raud' ,]
#pat = pat[pat$CHAN != 'Rocc.Laud' ,];pat = pat[pat$CHAN != 'Locc.Laud' ,];pat = pat[pat$CHAN != 'RLocc.Laud' ,]

#pat = pat[pat$CHAN != 'Rocc.RLaud' ,]
#pat = pat[pat$CHAN != 'Locc.RLaud' ,]
#pat = pat[pat$CHAN != 'RLocc.RLaud' ,]
#lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~TIME|DIR))#


#interaction.plot(pat$DIR, pat$TIME,
#                 pat$CORR, fun= mean,
#                 col=c(4,2,5),lwd = 4, lty = 1, legend = TRUE)

#a  = ezANOVA (pat, dv = .(CORR), wid = .(SUB), within= .(DIR,TIME), detailed=T,type=1)
#print(a)

#lsmeans::cld(lsmeans::lsmeans(model.pat,pairwise~CHAN|COND))
#lsmeans::cld(lsmeans::lsmeans(model.pat, "FREQ"))