library(dae);library(nlme);library(effects);
library(psych);library(interplot);library(plyr);
library(devtools);library(ez);library(Rmisc);
library(wesanderson);library(lme4);library(lsmeans);library(plotly);
library(ggplot2);library(ggpubr);library(dplyr)
library(ggthemes);library(extrafont)
library(car);library(ggplot2);library(optimx);library(simr)
library(tidyverse);library(hrbrthemes)
library(viridis);library(afex);library(multcomp);library(emmeans);
library(gridExtra);library(ez);library(rstatix)

rm(list=ls())
pd              <- position_dodge(0.1)
alphalev        <- 0.6

# dir_file          <- "/Users/heshamelshafei/gitHub/own/doc/"
# fname             <- paste0(dir_file,"eyes.behav2fft.","sensor",".","handle","outliers.csv")

dir_file          <- "/Users/heshamelshafei/Dropbox/project_me/doc/R/"
fname             <- paste0(dir_file,"eyes.behav2fft.sensor.vis.rel.","1s.","avgrel",".csv")

alldata               <- read.table(fname,sep = ',',header=T)
alldata               <- alldata[alldata$measure == "visual power",]

alldata$sub           <- as.factor(alldata$sub)
alldata$eyes          <- as.factor(alldata$eyes)
alldata$compare       <- as.factor(alldata$compare)
alldata$behavior      <- as.factor(alldata$cond)

alldata$eye           <- ordered(alldata$eye, levels = c("open", "closed"))
list_compare          <-  c("accuracy_e","rt") # "accuracy",

for (ncom in 1:length(list_compare)){
  
  rep_data            <- alldata[alldata$compare == list_compare[ncom],]
  rep_data$behavior   <- factor(rep_data$behavior)
  rep_data$var        <- rep_data$value

  list_behav          <- unique(rep_data$behavior)
  list_eyes           <- unique(rep_data$eyes)
  
  colormap            <- c("#8856a7","#43a2ca")
  round_val           <- 3
  
  # model_beh         <- lme4::lmer(var ~ (eye+behavior)^2 + (1|sub), data =rep_data)
  # model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
  # print(model_beh_anova)
  # res <-  emmeans(model_beh, pairwise ~ behavior | eye,adjust = "bonferroni")
  # print(res)
  print(list_compare[ncom])
  
  e_anova = ezANOVA(
    data = rep_data
    , dv = .(var)
    , wid = .(sub)
    , within = .(eye,behavior)
  )
  print(e_anova$ANOVA)
  
  map_name            <- c("#8856a7","#43a2ca")
  list_eyes           <- c("open","closed")
  
  for (neyes in 1:length(list_eyes)){
    
    sub_data <- rep_data[rep_data$eye == list_eyes[neyes],]
    sub_data$eyes      <- as.factor(sub_data$eye)
    
    limit_open <- c(-1,3)
    limit_close <- c(-1,1) #limit_open#
    
    if (neyes == 1){
      
      if (ncom == 2){
        plot_lim    <- c(-0.6,1.2)
        plot_break  <- c(-0.6,0,0.6,1.2)
      }
      
      if (ncom == 1){
        plot_lim    <- c(-0.3,0.9)
        plot_break  <- c(-0.3,0,0.3,0.6,0.9)
      }
      
    } else if (neyes == 2){
      
      plot_lim    <- c(-0.6,0.4)
      plot_break <- c(-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8)
      
    }
    
    pplot <- ggplot(sub_data, aes(x = behavior, y = var, fill = behavior)) +
      geom_line(aes(group=sub),color='gray',size=0.2,alpha=0.6)+
      geom_boxplot(outlier.shape = NA, alpha = .5, width = .35, colour = "black")+
      scale_colour_manual(values= map_name)+
      scale_fill_manual(values = map_name)+
      ggtitle(list_compare[ncom])+
      scale_y_continuous(name = "",limits = plot_lim, breaks =plot_break)+
      scale_x_discrete(name = list_eyes[neyes])+
      # ,labels = c("open" , "closed"))+
      theme_pubr(base_size = 13,base_family = "Calibri")+
      guides(fill=FALSE,color = FALSE, size = FALSE)
    
    if (ncom == 1 & neyes == 1){
      p1  = pplot
    } else if (ncom == 1 & neyes == 2){
      p3 = pplot
    } else if (ncom == 2 & neyes == 1){
      p2 = pplot 
    } else if (ncom == 2 & neyes == 2){
      p4 = pplot 
    } else if (ncom == 3 & neyes == 1){
      p5 = pplot 
    } else if (ncom == 3 & neyes == 2){
      p6 = pplot 
    }
    
  }
}

if (ncom == 3){
  fullfig <- ggarrange(p1,p3,p2,p4,p5,p6,ncol=2,nrow=3)
} else if (ncom == 2){
  fullfig <- ggarrange(p1,p3,p2,p4,ncol=4,nrow=1)
} else if (ncom == 1){
  fullfig <- ggarrange(p1,p3,ncol=2,nrow=1)
}

fullfig

ggsave(filename="/Users/heshamelshafei/Dropbox/project_me/figures/eyes/eyes_jun_final_visual_rel.svg",
       plot=fullfig,width=10,height=3)

# find_outlier          <- alldata[alldata$behavior == "cor_e" &
#                                    alldata$eyes == "open" &
#                                    alldata$value > 1,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# bad_suj

# bad_suj               <- c("sub011")
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }