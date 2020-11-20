library(car)
library(heplots)
library(lsr)

rm(list=ls())
ext1=  "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/doc/"
ext2  = "BigCovariance.HemiByModByTimeByFreqNewEvoked.txt"
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

pat   = pat[pat$TIME != "200ms",]
pat   = pat[pat$TIME != "300ms",]
pat   = pat[pat$TIME != "400ms",]
pat   = pat[pat$TIME != "500ms",]
pat   = pat[pat$TIME != "1100ms",]

pat

for (ntrl in 1:9072){
  pat[ntrl,8] <- paste0(pat[ntrl,3],pat[ntrl,4])
}

names(pat) <- c("SUB","COND","MODALITY","HEMI","FREQ","TIME", "POW","ChaName")
pat$ChaName <- factor(pat$ChaName)

model_four.pat   <- lme4::lmer(POW ~ (COND+HEMI+MODALITY+FREQ+TIME)^4  + (1|SUB), data =pat)
anova_four       <-Anova(model_four.pat,type=2,test.statistic=c("F"))

print(anova_four)

lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|HEMI),details= TRUE)



# --------------------------------------------------------------------- #

anova_five       <-Anova(model_five.pat,type=2,test.statistic=c("F"))
model_five.pat   <- lme4::lmer(POW ~ (COND+HEMI+MODALITY+FREQ+TIME)^5  + (1|SUB), data =pat)

model_romain.pat <- lme4::lmer(POW ~ (COND+HEMI+MODALITY+FREQ+TIME)^3  + COND:HEMI:MODALITY:FREQ + (1|SUB), data =pat)
anova_romain     <-Anova(model_romain.pat,type=2,test.statistic=c("F"))



save(model_four.pat,
     anova_four,
     file = "/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/r_data/for_paper_3models_plus_anova.RData")

# --------------------------- #


etasq(a, anova = TRUE)
ts = etaSquared(model.pat, type = 2, anova = TRUE )

print(a)

subpat = pat[pat$HEMI=="R",]

model.subpat  <- lme4::lmer(POW ~ (COND+MODALITY+FREQ)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2,test.statistic=c("F"))
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|MODALITY),details= TRUE)

b <- ezANOVA(pat,dv=.(POW),wid = .(SUB),within = .(COND,MODALITY,FREQ),detailed=T)
print(b)

# n2 = nom / [nom+dom]

subpat = pat[pat$HEMI=="R" ,]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ+MODALITY)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|MODALITY),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~FREQ|MODALITY),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "COND"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "MODALITY"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "FREQ"),details= TRUE)


subpat = pat[pat$HEMI=="L" ,]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ+MODALITY)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|MODALITY),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~FREQ|MODALITY),details= TRUE)

lsmeans::cld(lsmeans::lsmeans(model.subpat, "COND"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "MODALITY"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "FREQ"),details= TRUE)

subpat = pat[pat$HEMI=="L" & pat$MODALITY  =="aud",]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ)^2 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "FREQ"),details= TRUE)


subpat = pat[pat$HEMI=="L" & pat$MODALITY  =="occ",]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ)^2 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|FREQ))
lsmeans::cld(lsmeans::lsmeans(model.subpat, "COND"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "FREQ"),details= TRUE)


# --------------------------------------------------------------------------- #

subpat = pat[pat$MODALITY=="aud" ,]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ+HEMI)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(model.subpat, "COND"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "FREQ"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "HEMI"),details= TRUE)

lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|HEMI))
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|FREQ))
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~FREQ|HEMI))

subpat = pat[pat$MODALITY=="occ" ,]
model.subpat <- lme4::lmer(POW ~ (COND+FREQ+HEMI)^3 + (1|SUB), data =subpat)
sub_a         <-Anova(model.subpat,type=2)
print(sub_a)

lsmeans::cld(lsmeans::lsmeans(model.subpat, "COND"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "FREQ"),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat, "HEMI"),details= TRUE)

lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|HEMI),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~COND|FREQ),details= TRUE)
lsmeans::cld(lsmeans::lsmeans(model.subpat,  pairwise~FREQ|HEMI),details= TRUE)


tgc <- summarySE(pat, measurevar="POW", groupvars=c("COND","FREQ","ChaName"))

pd <- position_dodge(0.1) # move them .05 to the left and right

interaction.ABC.plot(POW, x.factor=FREQ,
                     groups.factor=COND, trace.factor=ChaName,
                     data=pat, c,
                     ggplotFunc=list(labs(x="Target Side",y="Relative power Change"),
                                                 ggtitle(""),ylim(-.3,.3),
                                                 geom_errorbar(data=tgc,aes(ymax=POW+se, ymin=POW-se),width=0.2,position=pd)),position=pd)
