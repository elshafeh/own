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
pd          <- position_dodge(0.1)
alphalev    <- 0.6

source("/Users/heshamelshafei/github/own/toolbox/RainCloudPlots/tutorial_R/summarySE.R")

dir_file          <- "/Users/heshamelshafei/gitHub/own/doc/"
fname             <- paste0(dir_file,"eyes_virt_stimlock_behav2fft.concat.adapted.peaks.500pre.csv")
alldata           <- read.table(fname,sep = ',',header=T)

alldata$sub       <- as.factor(alldata$sub)
alldata$eyes      <- as.factor(alldata$eyes)
alldata$measure   <- as.factor(alldata$measure)
alldata$roi       <- as.factor(alldata$roi)
alldata$cond      <- as.factor(alldata$cond)
alldata$compare   <- as.factor(alldata$compare)
alldata$window    <- as.factor(alldata$window)
alldata$peak      <- as.factor(alldata$peak)
alldata$band      <- as.factor(alldata$band)

alldata$eye        <- ordered(alldata$eye, levels = c("open", "closed"))

font_s              <- 10
list_band           <- unique(levels(alldata$band)) #c("alpha") # 
list_measure        <- unique(levels(alldata$measure)) # c("visual power") # 

for (nmes in 1:length(list_measure)){
  
  myplots           <- list()
  i                 <- 0
  
  for (nband in 1:length(list_band)){
    
    sub_table       <- alldata[alldata$band == list_band[nband] &  alldata$measure == list_measure[nmes],]
    sub_table$roi   <- factor(sub_table$roi)
    
    list_compare    <- unique(levels(sub_table$compare)) # c("accuracy","accuracy_e","rt") # 
    list_roi        <- unique(levels(sub_table$roi))
    
    for (nroi in 1:length(list_roi)){
      for (ncom in 1:length(list_compare)){
        
        rep_data            <- sub_table[sub_table$compare == list_compare[ncom] &sub_table$roi == list_roi[nroi],]
        rep_data$var        <- rep_data$value
        rep_data$behavior   <- factor(rep_data$cond)
        
        if (list_measure[nmes] == "somatovisual balance"){
          plot_lim            <- c(-1.5,1.5)
        } else if (list_measure[nmes] == "visual power"){
          plot_lim            <- c(-1,1)
        } else {
          plot_lim            <- c(-0.5,0.5)
        }
        
        colormap            <- c("#8856a7","#43a2ca")
        round_val           <- 3

        model_beh         <- lme4::lmer(var ~ (eye+behavior)^2 + (1|sub), data =rep_data)
        model_beh_anova   <- Anova(model_beh,type=2,test.statistic=c("F"))
        # pval1 <- round(model_beh_anova$`Pr(>F)`[1],round_val)
        # pval2 <- round(model_beh_anova$`Pr(>F)`[2],round_val)
        # pval3 <- round(model_beh_anova$`Pr(>F)`[3],round_val)

        e_anova = ezANOVA(
          data = rep_data
          , dv = .(var)
          , wid = .(sub)
          , within = .(eye,behavior)
        )

        pval1 <- round(e_anova$ANOVA$p[1],round_val)
        pval2 <- round(e_anova$ANOVA$p[2],round_val)
        pval3 <- round(e_anova$ANOVA$p[3],round_val)
        
        # cond_eye  =  "open"
        # list_test = unique(rep_data$behavior)
        # y1     = rep_data[rep_data$eye == cond_eye & rep_data$behavior==list_test[1],"var"]
        # y2     = rep_data[rep_data$eye == cond_eye & rep_data$behavior==list_test[2],"var"]
        # t.test(y1,y2,paired=TRUE)
        
        plimit <- 1
        
        if (pval2< plimit || pval3<plimit){
          p1                <- ggplot(rep_data, aes(x = eye, y = var, fill = behavior))+
            geom_boxplot(aes(x = eye, y = var, fill = behavior),outlier.shape = NA, 
                         alpha = .5, width = .5, colour = "black")+
            scale_fill_manual(values=colormap)+
            scale_color_manual(values=colormap)+
            ggtitle(paste0("p(behavior) = ",pval2,"\n",
                           "p(eye) = ", pval1,"\n",
                           "p(interaction) = ",pval3))+
            theme_pubclean(base_size = font_s,base_family = "Calibri")+
            scale_y_continuous(name = paste0(list_band[nband],"\n",list_measure[nmes]), limits = plot_lim)+
            scale_x_discrete(name = list_roi[nroi])
          
          i                 <- i+1
          myplots[[i]]      <- p1
        }

        rm(rep_data,pval1,pval2,pval3)
        
      }
    }
  }
  
  grid.arrange(grobs = myplots, 
               ncol = 3,nrow,3)
  
}


