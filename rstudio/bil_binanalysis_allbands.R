### Header ###
{library(dae);library(nlme);library(effects);
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
  
  # The palette with grey:
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
  ub <- function(x) mean(x) + sd(x)}
### Header ###

dir         <- "/Users/heshamelshafei/Documents/GitHub/me/doc/bil.allbandbinning.txt"
sub_table   <- read.table("/Users/heshamelshafei/Documents/GitHub/me/doc/bil.allbandbinning.txt",
                          sep = ',',header=T)

cbPalette <- c( "#0072B2", "#CC79A7")
pd        <- position_dodge(0.2)

model1.pat<- lme4::lmer(rt ~ (bin+win+band)^2 + (1|suj), data =sub_table)
model_anova1        <- Anova(model1.pat,type=2,test.statistic=c("F"))
print(model_anova1)

emmeans(model1.pat, pairwise ~ bin)
emmeans(model1.pat, pairwise ~ bin | band)

model2.pat<- lme4::lmer(corr ~ (bin+win+band)^3 + (1|suj), data =sub_table)
model_anova2        <- Anova(model2.pat,type=2,test.statistic=c("F"))
print(model_anova2)

alpha_table = sub_table[sub_table$band=="alpha",]
beta_table  = sub_table[sub_table$band=="beta",]
gamma_table = sub_table[sub_table$band=="gamma",]
theta_table = sub_table[sub_table$band=="theta",]

model3.pat<- lme4::lmer(corr ~ (bin+win)^2 + (1|suj), data =alpha_table)
model_anova3        <- Anova(model3.pat,type=2,test.statistic=c("F"))
print(model_anova3)
emmeans(model3.pat, pairwise ~ bin)

model3.pat<- lme4::lmer(corr ~ (bin+win)^2 + (1|suj), data =beta_table)
model_anova3        <- Anova(model3.pat,type=2,test.statistic=c("F"))
print(model_anova3)
emmeans(model3.pat, pairwise ~ bin | win)

model3.pat<- lme4::lmer(corr ~ (bin+win)^2 + (1|suj), data =theta_table)
model_anova3        <- Anova(model3.pat,type=2,test.statistic=c("F"))
print(model_anova3)
emmeans(model3.pat, pairwise ~ bin)

model3.pat<- lme4::lmer(corr ~ (bin+win)^2 + (1|suj), data =gamma_table)
model_anova3        <- Anova(model3.pat,type=2,test.statistic=c("F"))
print(model_anova3)
emmeans(model3.pat, pairwise ~ bin | win)

pd        <- position_dodge(0.5)

tgc <- summarySE(sub_table, measurevar="rt", groupvars=c("band","bin","win"))

ggplot(tgc, aes(x=bin, y=rt,colour=win,group = win))+
  geom_point(position=pd, size=3)+
  geom_line(position=pd,size=1) +
  geom_errorbar(aes(ymin=rt-se, ymax=rt+se), width=.5, position=pd) +
  ylim(0.85,1.1)+
  facet_wrap(~band)+
  theme_bw()

tgc <- summarySE(sub_table, measurevar="corr", groupvars=c("band","bin","win"))

ggplot(tgc, aes(x=bin, y=corr,colour=win,group = win)) + # ,colour=cue,group=cue
  geom_point(position=pd, size=3)+
  geom_line(position=pd,size=1) +
  geom_errorbar(aes(ymin=corr-se, ymax=corr+se), width=.5, position=pd) +
  ylim(0.75,0.85)+
  facet_wrap(~band)+
  theme_bw()


mini_table <- sub_table[sub_table$band=="alpha",]

tgc <- summarySE(sub_table, measurevar="pow_theta", groupvars=c("bin","win"))
ggplot(tgc, aes(x=bin, y=pow_theta))+
  geom_point(position=pd, size=3)+
  geom_line(position=pd,size=1) +
  geom_errorbar(aes(ymin=pow_theta-se, ymax=pow_theta+se), width=.5, position=pd) +
  facet_wrap(~win)+
  theme_bw()

tgc <- summarySE(sub_table, measurevar="pow_beta", groupvars=c("bin","win"))
ggplot(tgc, aes(x=bin, y=pow_beta))+
  geom_point(position=pd, size=3)+
  geom_line(position=pd,size=1) +
  geom_errorbar(aes(ymin=pow_beta-se, ymax=pow_beta+se), width=.5, position=pd) +
  facet_wrap(~win)+
  theme_bw()

tgc <- summarySE(sub_table, measurevar="pow_gamma", groupvars=c("bin","win"))
ggplot(tgc, aes(x=bin, y=pow_gamma))+
  geom_point(position=pd, size=3)+
  geom_line(position=pd,size=1) +
  geom_errorbar(aes(ymin=pow_gamma-se, ymax=pow_gamma+se), width=.5, position=pd) +
  facet_wrap(~win)+
  theme_bw()


# sub_table   <-sub_table[sub_table$win=="preGab1",]
# model1.pat<- lme4::lmer(rt ~ (bin+band)^2 + (1|suj), data =sub_table)
# model_anova1        <- Anova(model1.pat,type=2,test.statistic=c("F"))
# print(model_anova1)