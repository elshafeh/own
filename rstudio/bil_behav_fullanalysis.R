### Header ###
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
library(multcomp);library(emmeans)

rm(list=ls())
pd          <- position_dodge(0.1)
alphalev    <- 0.6

#:
cbPalette <- c( "#56B4E9", "#009E73")

raincloud_theme <- theme(
  text = element_text(size = 10),
  axis.title.x = element_text(size = 16),
  axis.title.y = element_text(size = 16),
  axis.text = element_text(size = 14),
  axis.text.x = element_text(angle = 45, vjust = 0.5),
  legend.title = element_text(size = 16),
  legend.text = element_text(size = 16),
  legend.position = "right",
  plot.title = element_text(lineheight = .8, face = "bold", size = 16),
  panel.border = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_blank(),
  axis.line.x = element_line(colour = "black", size = 0.5, linetype = "solid"),
  axis.line.y = element_line(colour = "black", size = 0.5, linetype = "solid"))

geom_flat_violin <- function(mapping = NULL, data = NULL, stat = "ydensity",
                             position = "dodge", trim = TRUE, scale = "area",
                             show.legend = NA, inherit.aes = TRUE, ...) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomFlatViolin,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      trim = trim,
      scale = scale,
      ...
    )
  )
}

GeomFlatViolin <-
  ggproto(
    "GeomFlatViolin",
    Geom,
    setup_data = function(data, params) {
      data$width <- data$width %||%
        params$width %||% (resolution(data$x, FALSE) * 0.9)
      
      # ymin, ymax, xmin, and xmax define the bounding rectangle for each group
      data %>%
        dplyr::group_by(.data = ., group) %>%
        dplyr::mutate(
          .data = .,
          ymin = min(y),
          ymax = max(y),
          xmin = x,
          xmax = x + width / 2
        )
    },
    
    draw_group = function(data, panel_scales, coord)
    {
      # Find the points for the line to go all the way around
      data <- base::transform(data,
                              xminv = x,
                              xmaxv = x + violinwidth * (xmax - x))
      
      # Make sure it's sorted properly to draw the outline
      newdata <-
        base::rbind(
          dplyr::arrange(.data = base::transform(data, x = xminv), y),
          dplyr::arrange(.data = base::transform(data, x = xmaxv), -y)
        )
      
      # Close the polygon: set first and last point the same
      # Needed for coord_polar and such
      newdata <- rbind(newdata, newdata[1,])
      
      ggplot2:::ggname("geom_flat_violin",
                       GeomPolygon$draw_panel(newdata, panel_scales, coord))
    },
    
    draw_key = draw_key_polygon,
    
    default_aes = ggplot2::aes(
      weight = 1,
      colour = "grey20",
      fill = "white",
      size = 0.5,
      alpha = NA,
      linetype = "solid"
    ),
    
    required_aes = c("x", "y")
  )

lb <- function(x) mean(x) - sd(x)
ub <- function(x) mean(x) + sd(x)

### Header ###

dir         <- "/Users/heshamelshafei/Documents/GitHub/me/doc/bil.behavioralReport.n34"
sub_table   <- read.table(paste0(dir,".keep.cor",".keep.rt",".txt"),
                          sep = ',',header=T)

# remove bad subjects
sub_table = sub_table[sub_table$suj!="sub007",]
sub_table$suj = factor(sub_table$suj)

# create summary table for % correct responses
sum_table   <- sub_table %>%
  group_by(suj,cue_type,feat_attend)%>%
  mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
  summarise(max(percent))

col_names                         = colnames(sum_table);
col_names[length((col_names))]    = "perc_corr";
names(sum_table)                  = col_names

model_acc.pat<- lme4::lmer(perc_corr ~ (feat_attend+cue_type)^2 + (1|suj), data =sum_table)
model_anova_acc        <- Anova(model_acc.pat,type=2,test.statistic=c("F"))
print(model_anova_acc)

# https://people.richland.edu/james/ictcm/2004/twoway.html --> for dF

emmeans(model_acc.pat, pairwise ~ feat_attend | cue_type)
emmeans(model_acc.pat, pairwise ~ feat_attend)
emmeans(model_acc.pat, pairwise ~ cue_type)

sum_table %>%
  ggplot( aes(x=feat_attend, y=perc_corr, fill=feat_attend)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("% correct") +
  xlab("")+scale_y_continuous(name="", limits=c(0.4, 1))+
  theme_clean()+facet_wrap(~cue_type)


# create summary table for RT
corr_table= sub_table[sub_table$corr_rep==1,]

sum_table   <- corr_table %>%
 group_by(suj,cue_type,feat_attend)%>%
 mutate(sj_rt = median(react_time)/1000) %>%
 summarise(max(sj_rt))

col_names                         = colnames(sum_table);
col_names[length((col_names))]    = "rt";
names(sum_table)                  = col_names

model_rt.pat<- lme4::lmer(rt ~ (feat_attend+cue_type)^2 + (1|suj), data =sum_table)
model_anova_rt        <- Anova(model_rt.pat,type=2,test.statistic=c("F"))
print(model_anova_rt)

emmeans(model_rt.pat, pairwise ~ feat_attend)
emmeans(model_rt.pat, pairwise ~ cue_type)

sum_table %>%
  ggplot( aes(x=feat_attend, y=perc_corr, fill=feat_attend)) +
  geom_boxplot() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("RT") +
  xlab("")+scale_y_continuous(name="", limits=c(0.2, 2))+theme_clean()
  +facet_wrap(~cue_type)

# ###Compare RT for match/non-match
# sum_table = sub_table[sub_table$corr_rep ==1,]
# 
# sum_table   <- sum_table %>%
#   group_by(suj,match)%>%
#   mutate(sj_rt = median(react_time)/1000) %>%
#   summarise(max(sj_rt))
# 
# col_names                         = colnames(sum_table);
# col_names[length((col_names))]    = "rt";
# names(sum_table)                  = col_names
# 
# sum_table$match = as.factor(sum_table$match)
# 
# sum_table$match = mapvalues(sum_table$match, 
#                                from = c("0", "1"), 
#                                to = c("no match", "match"))
# 
# res <- t.test(rt ~ match, data = sum_table, paired = TRUE)
# res
# 
# p1a <- ggplot(data = sum_table, 
#        aes(x = match, y = rt)) +
#   geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
#   geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5)+
#   scale_fill_ptol()+
#   guides(fill = FALSE) +
#   guides(color = FALSE) +
#   theme_ipsum() +
#   raincloud_theme+
#   xlab("")+ylab("")+ggtitle("p = 0.79")
# 
# #Compare RT for Correct/Incorrect
# 
# sum_table   <- sub_table %>%
#   group_by(suj,corr_rep)%>%
#   mutate(sj_rt = median(react_time)/1000) %>%
#   summarise(max(sj_rt))
# 
# col_names                         = colnames(sum_table);
# col_names[length((col_names))]    = "rt";
# names(sum_table)                  = col_names
# 
# sum_table$corr_rep = as.factor(sum_table$corr_rep)
# 
# sum_table$corr_rep = mapvalues(sum_table$corr_rep, 
#                             from = c("0", "1"), 
#                             to = c("incorrect", "correct"))
# 
# res <- t.test(rt ~ corr_rep, data = sum_table, paired = TRUE)
# res
# 
# p2a <- ggplot(data = sum_table,
#               aes(x = corr_rep, y = rt)) +
#   geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
#   geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5)+
#   scale_fill_ptol()+
#   guides(fill = FALSE) +
#   guides(color = FALSE) +
#   theme_ipsum() +
#   raincloud_theme+
#   xlab("")+ylab("")+ggtitle("p < 0.001")


# ggarrange(p1a,p2a,ncol=2,nrow=1)









# p1<-ggplot(data = sum_table,
# #        aes(x = feat_attend, y = perc_corr, fill = feat_attend)) +
# #   geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
# #   geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5)+
# #   scale_fill_ptol()+
# #   #guides(fill = FALSE) +
# #   #guides(color = FALSE) +
# #   #theme_ipsum() +
# #   raincloud_theme+
# #   facet_wrap(~cue_type)+
# #   xlab("")+ylab("")+ggtitle("% Correct")
# # # 
# p2<-ggplot(data = sum_table, 
#            aes(x = feat_attend, y = rt, fill = feat_attend)) +
#   geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
#   geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5)+
#   scale_fill_ptol()+
#   guides(fill = FALSE) +
#   guides(color = FALSE) +
#   theme_ipsum() +
#   raincloud_theme+
#   facet_wrap(~cue_type)+
#   xlab("")+ylab("")+ggtitle("Median RT")
# 
# ggarrange(p1,p2,ncol=2,nrow=1)



# # check % of behavioral rejection
# sum_table   <- sub_table %>%
#   group_by(suj)%>%
#   mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot)%>%
#   summarise(max(percent)*100)
# 
# col_names                         = colnames(sum_table);
# col_names[length((col_names))]    = "perc_corr";
# names(sum_table)                  = col_names
# 
# rej_limit = 55
# 
# ggplot(sum_table, aes(x=suj, y=perc_corr, label=suj)) + 
#   geom_point(show.legend = FALSE,size=3)+
#   geom_hline(yintercept=rej_limit, linetype="dashed", 
#              color = "black", size=1)+
#   geom_text(aes(label=ifelse(perc_corr<rej_limit,as.character(suj),'')),hjust=0,vjust=1.5,color = "red")+
#   theme(axis.ticks= element_blank(),
#         axis.text.x=element_blank())+
#   ylim(c(50,100))+
#   theme(axis.title.x=element_blank(),
#         axis.ticks.x=element_blank(),
#         axis.title.y=element_blank())
# 
# sub_table$bloc_nb <- as.factor(sub_table$bloc_nb)

# # p4<- ggplot2::ggplot(tgc, aes(x=feat_attend, y=var, fill=cue_type)) +
# #   geom_bar(position=position_dodge(), stat="identity") +
# #   geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
# #   ylim(0,2)+
# #   scale_fill_manual(values=cbPalette)+ 
# #   scale_colour_manual(values=cbPalette)+
# #   theme_clean()+
# #   ylab("Reaction time")
# 
# # per correct per block
# 
# sum_table_corr   <- sub_table %>%
#   group_by(suj,bloc_nb)%>%
#   mutate(tot= length(corr_rep), len= sum(corr_rep),percent = len/tot) %>%
#   summarise(max(percent))
# 
# col_names = colnames(sum_table_corr);
# col_names[length((col_names))]  = "var";
# names(sum_table_corr)                = col_names
# 
# tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("bloc_nb"))
# 
# p5 <- ggplot(tgc, aes(x=bloc_nb, y=var)) + 
#   geom_point(position=pd, size=2)+
#   geom_line(position=pd) +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se), width=.1, position=pd) +
#   ylim(0.65,1)+
#   theme_classic2()+
#   scale_fill_manual(values=cbPalette)+ 
#   scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("% Correct")
# 
# sum_table_rt   <- sub_table %>%
#   group_by(suj,bloc_nb)%>% 
#   mutate(sj_rt = median(react_time)/1000) %>%
#   summarise(max(sj_rt))
# 
# col_names = colnames(sum_table_rt);
# col_names[length((col_names))]  = "var";
# names(sum_table_rt)                = col_names
# 
# tgc <- summarySE(sum_table_rt, measurevar="var", groupvars=c("bloc_nb"))
# 
# p6 <- ggplot(tgc, aes(x=bloc_nb, y=var)) + 
#   geom_point(position=pd, size=2)+
#   geom_line(position=pd) +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se), width=.1, position=pd) +
#   ylim(0.5,1.5)+
#   theme_classic2()+
#   scale_fill_manual(values=cbPalette)+ 
#   scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("Reaction time")
# 
# 
# ## RT per correct
# 
# sum_table_rt   <- sub_table %>%
#   group_by(suj,corr_rep)%>% 
#   mutate(sj_rt = median(react_time)/1000) %>%
#   summarise(max(sj_rt))
# 
# sum_table_rt$corr_rep = factor(sum_table_rt$corr_rep)
# 
# col_names = colnames(sum_table_rt);
# col_names[length((col_names))]  = "var";
# names(sum_table_rt)                = col_names
# 
# sum_table_rt$corr_rep = mapvalues(sum_table_rt$corr_rep, from = c("0", "1"), to = c("incorrect", "correct"))
# 
# tgc <- summarySE(sum_table_rt, measurevar="var", groupvars=c("corr_rep"))
# 
# p7<- ggplot2::ggplot(tgc, aes(x=corr_rep, y=var)) +
#   geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
#   ylim(0,2)+
#   #scale_fill_manual(values=cbPalette)+ 
#   #scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("Reaction time")
# 
# 
# # RT of match % non-match
# sum_table_corr   <- sub_table %>%
#   group_by(suj,sub_match)%>%
#   mutate(sj_rt = median(react_time)/1000) %>%
#   summarise(max(sj_rt))
# 
# col_names = colnames(sum_table_corr);
# col_names[length((col_names))]  = "var";
# names(sum_table_corr)                = col_names
# 
# sum_table_corr$sub_match = mapvalues(sum_table_corr$sub_match, from = c("0", "1"), to = c("no-match", "match"))
# 
# tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("sub_match"))
# 
# p8 <- ggplot2::ggplot(tgc, aes(x=sub_match, y=var)) +
#   geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
#   ylim(0,2)+
#   #scale_fill_manual(values=cbPalette)+ 
#   #scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("Reaction time")
# 
# # RT of button A/B
# 
# sub_table = sub_table[sub_table$rep_button > 0,]
# 
# sum_table_corr   <- sub_table %>%
#   group_by(suj,rep_button)%>%
#   mutate(sj_rt = median(react_time)/1000) %>%
#   summarise(max(sj_rt))
# 
# col_names = colnames(sum_table_corr);
# col_names[length((col_names))]  = "var";
# names(sum_table_corr)                = col_names
# 
# sum_table_corr$rep_button = mapvalues(sum_table_corr$rep_button, from = c("1", "2"), to = c("A", "B"))
# 
# tgc <- summarySE(sum_table_corr, measurevar="var", groupvars=c("rep_button"))
# 
# p9 <- ggplot2::ggplot(tgc, aes(x=rep_button, y=var)) +
#   geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=var-se, ymax=var+se),width=.2,position=position_dodge(.9))+
#   ylim(0,2)+
#   #scale_fill_manual(values=cbPalette)+ 
#   #scale_colour_manual(values=cbPalette)+
#   theme_clean()+
#   ylab("Reaction time")
# 
# ggarrange(p1,p3,p5,p6,p7,p8,p9,ncol = 3, nrow = 3)
# 
# # model1          <- lme4::lmer(var ~ (feat_attend+cue_type)^2 + (1|suj), data =sum_table_corr)
# # model_anova1     <- Anova(model1,type=2,test.statistic=c("F"))
# # print(model_anova1)
# # 
# # lsmeans(model1,   pairwise~feat_attend|cue_type,details= TRUE)
# # lsmeans(model1,   pairwise~cue_type|feat_attend,details= TRUE)
# # 
# # model2          <- lme4::lmer(var ~ (feat_attend+cue_type)^2 + (1|suj), data =sum_table_rt)
# # model_anova2    <- Anova(model2,type=2,test.statistic=c("F"))
# # print(model_anova2)
# # 
# # lsmeans(model2,   pairwise~feat_attend|cue_type,details= TRUE)
# # lsmeans(model2,   pairwise~cue_type|feat_attend,details= TRUE)