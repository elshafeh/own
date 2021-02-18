library(dae);library(nlme);library(effects);
library(psych);library(interplot);library(plyr);
library(devtools);library(ez);library(Rmisc);
library(wesanderson)
library(lme4);library(lsmeans);library(plotly);
library(ggplot2);library(ggpubr);library(dplyr)
library(ggthemes);library(extrafont)
library(car);library(ggplot2)
library(optimx);library(simr)
library(tidyverse)
library(hrbrthemes)
library(viridis);library(afex)
library(multcomp);library(emmeans);
library(gridExtra);library(ez)

rm(list=ls())
pd                  <- position_dodge(0.2)
alphalev            <- 0.6

<<<<<<< HEAD
fname       <- "/Users/heshamelshafei/gitHub/own/doc/eyes_sens_peakinfo.csv"
sub_table   <- read.table(fname,sep = ',',header=T)

sub_table$sub     = as.factor(sub_table$sub)
sub_table$eyes    = as.factor(sub_table$eyes)
sub_table$roi     = as.factor(sub_table$roi)
sub_table$level   = as.factor(sub_table$level)

myplots             <- list()
i                   <- 0

for (npeak in 1:2){
  
  rep_data        <- sub_table
  rep_data$eye    <- ordered(rep_data$eye, levels = c("open", "closed"))
  rep_data$roi    <- ordered(rep_data$roi, levels = c("somato", "visual","auditory"))
  
  if (npeak == 1){
    rep_data$var = rep_data$apeak
    plot_lim      = c(6,14)
  } else if (npeak == 2){
    rep_data$var = rep_data$bpeak
    plot_lim      = c(15,25)
  }
  
  model_beh           <- lme4::lmer(var ~ (eye+roi)^2 + (1|sub), data =rep_data)
  model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  emmeans(model_beh, pairwise ~ roi)
  
  pval1 <- round(model_beh_anova$`Pr(>F)`[1],2)
  pval2 <- round(model_beh_anova$`Pr(>F)`[2],2)
  pval3 <- round(model_beh_anova$`Pr(>F)`[3],2)
  
  list_peak           <- c("Alpha Peak Frequency","Beta Peak Frequency")
  
  p1                  <- ggplot(rep_data, aes(x = roi, y = var, colour = roi)) +
    geom_boxplot()  + # boxplot
    geom_point(aes(group=sub),position=position_dodge(0.3)) + # dots
    scale_y_continuous(name=list_peak[npeak],limits =plot_lim,breaks = seq(plot_lim[1],plot_lim[2],by = 1)) + # y axis
    scale_x_discrete(name="") + # x axis
    theme_pubclean(base_size = 14,base_family = "Calibri")
  
    p1  <-set_palette(p1,'jco')
    
    
    # ggplot(rep_data, aes(x = roi, y = var))+
    # geom_boxplot(outlier.shape = NA,
    #              alpha = .5, width = .5, colour = "black")+
    # scale_colour_brewer(palette = "Dark2")+
    # scale_fill_brewer(palette = "Dark2")+
    # ggtitle(paste0("p[eye] = ",pval1,
    #                "\n p[roi] = ",pval2,
    #                "\n p[eye*roi] = ",pval3))+
    # theme_pubclean(base_size = 12,base_family = "Calibri")+
    # scale_y_continuous(name = list_peak[npeak],limits = plot_lim)+
    # scale_x_discrete(name = "")#+facet_wrap(~level)
  
  i                   <- i+1
  myplots[[i]]        <- p1
  
}

if (length(myplots) > 0){
  grid.arrange(grobs = myplots, ncol = 2,nrow,1)
}
=======
cbPalette_eyes      <- c("#669933","#FFCC33") 

fname               <- "P:/3015039.05/data/all_sub/eyes_virt_alphabeta_peak_info.csv"
sub_table           <- read.table(fname,sep = ',',header=T)

model_peak        <- lme4::lmer(apeak ~ (eye+roi+hemi)^2 + (1|sub), data =sub_table)
model_peak_anova  <- Anova(model_peak,type=2,test.statistic=c("F"))
print(model_peak_anova)

emmeans(model_peak, pairwise ~ roi)
emmeans(model_peak, pairwise ~ eye | roi)
emmeans(model_peak, pairwise ~ roi | eye)

y_lim <- c(5,15)

p1 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("alpha peak: roi p < 0.001") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()

p2 <- sub_table %>%
  ggplot( aes(x=roi, y=apeak, fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("alpha peak: eye*roi p = 0.04") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_eyes)+
  scale_fill_manual(values = cbPalette_eyes)

model_peak        <- lme4::lmer(bpeak ~ (eye+roi+hemi)^3 + (1|sub), data =sub_table)
model_peak_anova  <- Anova(model_peak,type=2,test.statistic=c("F"))
print(model_peak_anova)


y_lim <- c(10,40)

p3 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()

p4 <- sub_table %>%
  ggplot( aes(x=roi, y=bpeak, fill=eye)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("beta peak") +
  xlab("")+scale_y_continuous(name="", limits=y_lim)+
  theme_clean()+scale_colour_manual(values = cbPalette_eyes)+
  scale_fill_manual(values = cbPalette_eyes)

ggarrange(p1,p2,p3,p4,ncol=2,nrow=2)
>>>>>>> 6a9ca58b7d384e0e358287d71e8e55c77001b619
