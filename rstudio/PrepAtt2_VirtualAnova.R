install.packages('devtools',type='source')
library(devtools)
dev_mode()
#install_github('ez','mike-lawrence')
library(ez)

pat=read.table("/Volumes/PAT_MEG/Fieldtripping/txt/CorrAnova.txt",header=T)

t1 = subset(pat,CHAN=="maxHL")
t1 = subset(t1,FREQ=="12Hz")
a  = ezANOVA (t1, dv = .(CORR), wid = .(SUB), within= .(COND), detailed=T,type=1)
print(a)

#a1 = ezANOVA (control, dv = .(medianRT), wid = .(SUB), within= .(CUE,DIS), detailed=T)
#print(a1)
#a2 = ezANOVA (patient, dv = .(medianRT), wid = .(SUB), within= .(CUE,DIS), detailed=T)
#print(a2)

interaction.plot(pat$DIS, pat$CUE,
                 pat$medianRT, fun= mean,
                 col=c(4,2,5),lwd = 4, lty = 1, legend = TRUE,xlab="Distractor", ylab="Median RT")

model.pat<- lme4::lmer(pat$medianRT ~ CUE*DIS + (1|SUB), data =pat)

lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~DIS|CUE))
lsmeans::cld(lsmeans::lsmeans(model.pat, pairwise~CUE|DIS))

#plotresid(model.HF.4, shapiro=TRUE)

#t1=subset(pat,BLOC!="B11")
#t2=subset(t1,BLOC!="B12")
#t3=subset(t2,BLOC!="B13")
#t4=subset(t3,BLOC!="B14")
#t5=subset(t4,BLOC!="B15")
#pat=t5
#pat$BLOC <- factor(pat$BLOC)
#remove(t1,t2,t3,t4,t5)
#a = ezANOVA (pat, dv = .(RT), wid = .(SUB),within= .(CUE,DIS), detailed=T)
#print(a)
#p =ezPerm(pat, dv=.(RT), wid=.(SUB), within=.(CUE,DIS))
#print(int)
#b = ezPlot (pat, dv = .(RT), wid = .(SUB),within= .(CUE,DIS),x=.(CUE),do_line=TRUE)
#print(b)
#print(a)
