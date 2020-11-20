library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);
library(lme4);library(lsmeans);library(ggplot2);library(RColorBrewer)
library(ggsci);library(sjstats)
library(pwr);library(emmeans);library(optimx)
library(multcomp)

rm(list=ls())
pd          <- position_dodge(0.1)
alphalev    <- 0.6

# The palette with grey:
cbPalette <- c( "#56B4E9", "#009E73")


sub_table   <- read.table("/Users/heshamelshafei/GoogleDrive/NeuroProj/PhD/Fieldtripping/documents/ageingperf_with_dis_freq.txt",
                          sep = ',',header=T)


sub_table    <- sub_table[sub_table$CORR==1 & sub_table$dis_delay != 'DIS0' & sub_table$dis_pitch != 'mid',]
sub_table$dis_delay = factor(sub_table$dis_delay)
sub_table$dis_pitch = factor(sub_table$dis_pitch)

#sum_table_rt   <- sub_table %>%
#  group_by(suj,group,dis_concat)%>% 
#  mutate(sj_rt = median(RT)) %>%
#  summarise(max(sj_rt))

sum_table_rt   <- sub_table %>%
  group_by(suj,group,dis_delay,dis_pitch)%>% 
  mutate(sj_rt = median(RT)) %>%
  summarise(max(sj_rt))

col_names = colnames(sum_table_rt);
col_names[length((col_names))]  = "RT";
names(sum_table_rt)                = col_names

write.csv(sum_table_rt,"/Users/heshamelshafei/Desktop/dis_data_bayesian.csv", row.names = FALSE)

model.pat   <- lme4::lmer(RT ~ (group+dis_pitch+dis_delay)^3 + (1|suj), data =sum_table_rt,REML = TRUE,
                          control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb')))


model_anova         <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

eta_sq(model.pat, partial = FALSE, ci.lvl = NULL, n = 1000, method = c("dist", "quantile"))
anova_stats(model.pat, digits = 3)

lsmeans(model.pat,  pairwise~dis_pitch|dis_delay,details= TRUE)


tgc <- summarySE(sum_table_rt, measurevar="RT", groupvars=c("group","dis_delay","dis_pitch"))

ggplot(tgc, aes(x=dis_delay, y=RT,colour=dis_pitch,group=dis_pitch)) + 
  geom_point(position=pd, size=2)+
  geom_line(position=pd) +
  geom_errorbar(aes(ymin=RT-se, ymax=RT+se), width=.1, position=pd) +
  ylim(400,700)+
  theme_classic()+
  scale_color_grey()+
  #scale_fill_manual('values=cbPalette'Dark2)+ 
  #scale_colour_manual(values=cbPalette)+
  facet_grid(.~ group)

