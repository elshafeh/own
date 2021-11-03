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

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

pd                <- position_dodge(0.1)
erbar_w           <- .08
erbar_s           <- .5
scat_s            <- 1.5
mean_s            <- 2.5
font_s            <- 16

fname               <- "/Users/heshamelshafei/gitHub/own/doc/eyes_sens_peakinfo.csv"
sub_table           <- read.table(fname,sep = ',',header=T)
sub_table <- sub_table[sub_table$roi != "auditory",]

sub_table$sub     = as.factor(sub_table$sub)
sub_table$eyes    = as.factor(sub_table$eyes)
sub_table$roi     = as.factor(sub_table$roi)
sub_table$level   = as.factor(sub_table$level)

myplots             <- list()
i                   <- 0

for (npeak in 1){
  
  rep_data        <- sub_table
  rep_data$eye    <- ordered(rep_data$eye, levels = c("open", "closed"))
  rep_data$roi    <- ordered(rep_data$roi, levels = c("somato", "visual"))
  
  if (npeak == 1){
    rep_data$var = rep_data$apeak
    plot_lim      = c(5,15,1)
  } else if (npeak == 2){
    rep_data$var = rep_data$bpeak
    plot_lim      = c(14,30,2)
  }
  
  model_beh           <- lme4::lmer(var ~ (eye+roi)^2 + (1|sub), data =rep_data)
  model_beh_anova     <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  emmeans(model_beh, pairwise ~ roi)
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,roi)
  )
  print(e_anova$ANOVA)
  
  pval1 <- round(model_beh_anova$`Pr(>F)`[1],2)
  pval2 <- round(model_beh_anova$`Pr(>F)`[2],2)
  pval3 <- round(model_beh_anova$`Pr(>F)`[3],2)
  
  list_peak           <- c("Alpha Peak Frequency","Beta Peak Frequency")
  
  cmap = "PRGn"
  
  pplot <- ggplot(rep_data, aes(x = roi, y = var, fill = roi)) +
    geom_flat_violin(aes(roi),position = position_nudge(x = .2, y = 0), adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
    geom_boxplot(alpha = .5, width = .35, colour = "black")+
    scale_fill_grey(start = 0.6, end = 0.1)+
    # scale_colour_brewer(palette = cmap)+
    # scale_fill_brewer(palette = cmap)+
    ggtitle(paste0("p[eye] = ",pval1,
                   "\np[roi] = ",pval2,
                   "\np[eye*roi] = ",pval3))+
    scale_y_continuous(name = list_peak[npeak], breaks =seq(plot_lim[1], plot_lim[2], by = plot_lim[3]),
                       limits = c(plot_lim[1], plot_lim[2]))+
    scale_x_discrete(name = "")+
    theme_pubclean(base_size = font_s,base_family = "Calibri")+
    guides(fill=FALSE,color = FALSE, size = FALSE)
  
  if (npeak == 1){
    p1  = pplot
  } else if (npeak == 2){
    p2 = pplot
  }
  
}

sumrepdat     <- summarySE(rep_data, measurevar = "var")


p1

# fullfig <- ggarrange(p1,p2,ncol=2,nrow=1)
# ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/presentations/eyes2021/svg/eyes_peakclouds.SVG",
#        plot=fullfig,width=6,height=3.5)
# fullfig