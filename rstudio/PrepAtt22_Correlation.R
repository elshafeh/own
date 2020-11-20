library(car) ;library(dae) ;library(nlme) ;library(effects)
library(ggplot2) ;library(psych) ;library(interplot)
library(plyr) ;library(devtools);library(ez)
library(Rmisc)
library(wesanderson)
library(Hmisc)

rm(list=ls())
ext1  = "/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/4R/";
ext2  = "Allyoung.RamaVirtual.AudLAudR.AlphaGamma.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

pat   = pat[pat$TIME == "600ms" | pat$TIME == "700ms" | pat$TIME == "800ms" | pat$TIME == "900ms",]
pat   = pat[pat$CHAN=="audR",]

pat_low   = pat[pat$FREQ == "65Hz" | pat$FREQ == "75Hz" | pat$FREQ == "85Hz" | pat$FREQ == "95Hz",]
pat_high  = pat[pat$FREQ == "7Hz" | pat$FREQ == "8Hz" | pat$FREQ == "9Hz" | pat$FREQ == "10Hz",]

suj_list <- as.character(unique(pat$SUB))
cue_list <- as.character(unique(pat$CUE))
cat_list <- as.character(unique(pat$CUE_CAT))

for (ncue in 1:length(cue_list)){
  for (ncat in 1:length(cat_list)){
    
    data_low <- pat_low[pat_low$CUE==cue_list[ncue] & pat_low$CUE_CAT ==cat_list[ncat],]
    data_low <- aggregate(data_low[, 7], list(data_low$SUB), mean)
    
    data_high <- pat_high[pat_high$CUE==cue_list[ncue] & pat_high$CUE_CAT ==cat_list[ncat],]
    data_high <- aggregate(data_high[, 7], list(data_high$SUB), mean)
    
    data      <- cbind(data_low,data_high[,2])
    names(data) <- c("SUB","PowLow","PowHigh")
    
    #res <- cor.test(x=data$PowLow, y=data$PowHigh, method = 'spearman')
    
    #print(res)
    
    #plot(PowLow ~ PowHigh, 
    #     data=data, 
    #    pch=16)
    
    alli.mod = lm(data$PowLow ~ data$PowHigh, data = data)
    summary(alli.mod)
    
  } 
}
