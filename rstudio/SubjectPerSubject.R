rm(list=ls())
ext1  = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/";
ext2  = "BehavioralSummaryUninformativeDivided.txt";
fname = paste0(ext1,ext2, collapse = NULL);
all_pat   = read.table(fname,header=T)

all_pat$XP <- factor(all_pat$XP) ; all_pat$REP <- factor(all_pat$REP) ; 
all_pat$CORR <- factor(all_pat$CORR) ; all_pat$ERROR <- factor(all_pat$ERROR) 
all_pat$TAR_PITCH <- factor(all_pat$TAR_PITCH)

all_pat   <- all_pat[all_pat$CORR==1 & all_pat$ERROR==0,]

#all_pat   <- all_pat[all_pat$RT > 199,]
#ggplot(all_pat, aes(x=SUB, y=RT, color=GROUP)) + geom_boxplot()