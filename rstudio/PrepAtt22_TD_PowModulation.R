library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)

rm(list=ls())

ext1      = "/Users/heshamelshafei/Desktop/"
ext2      = "BroadMan_AllYc_Alpha_TD_Attention_MinEvoked_100Slct.txt"
pat       =  read.table(paste0(ext1,ext2),header=T)
pat       = pat[pat$CHAN == "7Networks_LH_DorsAttn_FEF_1" | pat$CHAN == "7Networks_LH_DorsAttn_FEF_2" | pat$CHAN == "7Networks_LH_DorsAttn_Post_1" | 
                  pat$CHAN == "7Networks_LH_DorsAttn_Post_2" | pat$CHAN == "7Networks_LH_DorsAttn_Post_3" | 
                  pat$CHAN == "7Networks_LH_DorsAttn_Post_4" | pat$CHAN == "7Networks_LH_DorsAttn_Post_5" | pat$CHAN == "7Networks_LH_DorsAttn_Post_6",]

ext1      = "/Users/heshamelshafei/Desktop/"
ext2      = "BroadMan_AllYc_Alpha_TD_Attention_MinEvoked_100Slct.txt"
pat_all   =  read.table(paste0(ext1,ext2),header=T)

pat_all       = pat_all[pat_all$CHAN == "7Networks_LH_DorsAttn_FEF_1" | pat_all$CHAN == "7Networks_LH_DorsAttn_FEF_2" | pat_all$CHAN == "7Networks_LH_DorsAttn_Post_1" | 
                          pat_all$CHAN == "7Networks_LH_DorsAttn_Post_2" | pat_all$CHAN == "7Networks_LH_DorsAttn_Post_3" | 
                          pat_all$CHAN == "7Networks_LH_DorsAttn_Post_4" | pat_all$CHAN == "7Networks_LH_DorsAttn_Post_5" | pat_all$CHAN == "7Networks_LH_DorsAttn_Post_6",]

model.pat   <- lme4::lmer(POW ~ (CUE_ORIG+CHAN)^2 + (1|SUB), data =pat)
model.pat_all   <- lme4::lmer(POW ~ (CUE_ORIG+CHAN)^2 + (1|SUB), data =pat_all)

model_anova <-Anova(model.pat,type=2,test.statistic=c("F"))
model_anova_all <-Anova(model.pat_all,type=2,test.statistic=c("F"))

print(model_anova)
print(model_anova_all)
