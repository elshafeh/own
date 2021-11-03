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
library(rstatix)

rm(list=ls())
pd              <- position_dodge(0.1)
alphalev        <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

dir_file              <- "/Users/heshamelshafei/gitHub/own/doc/"
ext_special           <- "0.5s"
fname                 <- paste0(dir_file,"eyes.behav.fft.clean.vis.relative.",ext_special,".csv")
alldata               <- read.table(fname,sep = ',',header=T)

alldata$sub           <- as.factor(alldata$sub)
alldata$eyes          <- as.factor(alldata$eyes)
alldata$compare       <- as.factor(alldata$big)
alldata$behavior      <- as.factor(alldata$small)

alldata$eye           <- ordered(alldata$eye, levels = c("open", "closed"))
list_compare          <-  c("accuracy_e","rt") # 

# 
# find_outlier          <- alldata[alldata$behavior == "fast" &
#                                    alldata$eyes == "closed" &
#                                    alldata$val > 0.35,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# 
# alldata$sub           <- factor(alldata$sub)

for (ncom in 1:length(list_compare)){
  
  rep_data            <- alldata[alldata$compare == list_compare[ncom],]
  rep_data$behavior   <- factor(rep_data$behavior)
  rep_data$compare    <- factor(rep_data$compare)
  
  rep_data$var        <- rep_data$val
  ext_focus           <- "relative visual"
  
  # # remove outliers
  # x                   <- rep_data$var
  # qnt                 <- quantile(x, probs=c(.25, .75))
  # caps                <- quantile(x, probs=c(.05, .95))
  # H                   <- 1.5 * IQR(x)
  # x[x < (qnt[1] - H)] <- caps[1]
  # x[x > (qnt[2] + H)] <- caps[2]
  # rep_data$var        <- x
  
  model_beh         <- lme4::lmer(var ~ (eye+behavior)^2 + (1|sub), data =rep_data)
  model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
  print(model_beh_anova)
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,behavior)
  )
  print(e_anova$ANOVA)

  # res <- emmeans(model_beh, pairwise ~ behavior)
  # print(res)
  
  map_name            <- c("#8856a7","#43a2ca")
  list_eyes           <- c("open","closed")
  
  for (neyes in 1:length(list_eyes)){
    
    sub_data <- rep_data[rep_data$eye == list_eyes[neyes],]
    sub_data$eyes      <- as.factor(sub_data$eyes)
    
    # res             <- t.test(var ~ behavior, data = sub_data,paired=TRUE)
    # print(res)
    
    limit_open <- c(-0.5,2) # c(-0.8,2)#
    limit_close <- c(-0.8,1) #limit_open#
    
    if (ncom == 1 & neyes == 1){
      plot_lim <- limit_open
    } else if (ncom == 1 & neyes == 2){
      plot_lim <- limit_close
    } else if (ncom == 2 & neyes == 1){
      plot_lim <- limit_open
    } else if (ncom == 2 & neyes == 2){
      plot_lim <-limit_close
    }
    
    pplot <- ggplot(sub_data, aes(x = behavior, y = var, fill = behavior)) +
      geom_line(aes(group=sub),color='gray',size=0.2,alpha=0.6)+
      # geom_boxplot(alpha = .5, width = .35, colour = "black")+
      geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
      scale_colour_manual(values= map_name)+
      scale_fill_manual(values = map_name)+
      ggtitle(list_compare[ncom])+
      # scale_y_continuous(name = ext_focus,limits = plot_lim, 
                         # breaks =round(seq(plot_lim[1], plot_lim[2], by = 0.2),1))+
      scale_x_discrete(name = list_eyes[neyes])+
      # ,labels = c("open" , "closed"))+
      theme_pubr(base_size = 12,base_family = "Calibri")+
      guides(fill=FALSE,color = FALSE, size = FALSE)
    
    if (ncom == 1 & neyes == 1){
      p1  = pplot
    } else if (ncom == 1 & neyes == 2){
      p3 = pplot
    } else if (ncom == 2 & neyes == 1){
      p2 = pplot 
    } else if (ncom == 2 & neyes == 2){
      p4 = pplot 
    }
    
  }
  

  
}

fullfig <- ggarrange(p1,p2,p3,p4,ncol=4,nrow=1)
fullfig

ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/figures/eyes/eyes_final_visual_norm.svg",
       plot=fullfig,width=10,height=3)


# alldata <- alldata[alldata$sub != "sub017",]

# find_outlier          <- alldata[alldata$behavior == "incorr_e" &
#                                    alldata$eyes == "open" &
#                                    alldata$val > 1,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# 
# find_outlier          <- alldata[alldata$behavior == "fast" &
#                                    alldata$eyes == "open" &
#                                    alldata$val > 1,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# 
# find_outlier          <- alldata[alldata$behavior == "fast" &
#                                    alldata$eyes == "open" &
#                                    alldata$val < -0.5,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# 
# find_outlier          <- alldata[alldata$behavior == "corr_e" &
#                                    alldata$eyes == "open" &
#                                    alldata$val > 1,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }