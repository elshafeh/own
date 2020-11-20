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

dir         <- "/Users/heshamelshafei/Documents/GitHub/me/doc/bil.alphabinning.5bins.final"
sub_table   <- read.table(paste0(dir,".txt"),
                          sep = ',',header=T)

cbPalette <- c( "#0072B2", "#CC79A7")
pd        <- position_dodge(0.2)


sub_table$win = mapvalues(sub_table$win, 
                               from = c("preCue1", "preCue2","preProbe","preTarget"), 
                               to = c("Pre 1st Cue", "Pre 2nd Cue","Pre 1st Gabor", "Pre 2nd Gabor"))

sub_table = sub_table[sub_table$cue == "all",]
sub_table$cue = factor(sub_table$cue)

# sub_table = sub_table[sub_table$win == "Pre 1st Gabor" | sub_table$win == "Pre 2nd Gabor",]
# sub_table$win = factor(sub_table$win)

model1.pat<- lme4::lmer(rt ~ (bin+win+cue)^3 + (1|suj), data =sub_table)
model_anova1        <- Anova(model1.pat,type=2,test.statistic=c("F"))
print(model_anova1)

summary(as.glht(update(pairs(emmeans(model1.pat, "bin")), by = NULL)))
emmeans(model1.pat, pairwise ~ bin | win)

model2.pat    <- lme4::lmer(corr ~ (bin+win+cue)^3 + (1|suj), data =sub_table)
model_anova2  <- Anova(model2.pat,type=2,test.statistic=c("F"))
print(model_anova2)
summary(as.glht(update(pairs(emmeans(model2.pat, "bin")), by = NULL)))

### plot all factors


tgc <- summarySE(sub_table, measurevar="corr", groupvars=c("bin","win"))

ggplot(tgc, aes(x=bin, y=corr)) + # ,colour=cue,group=cue
  geom_point(position=pd, size=3)+
  geom_line(size=1) +
  geom_errorbar(aes(ymin=corr-se, ymax=corr+se), width=.5, position=pd) +
  ylim(0.75,0.85)+
  facet_wrap(~win)+
  theme_bw()+
  raincloud_theme+
  scale_colour_manual(values = cbPalette)+
  scale_fill_manual(values = cbPalette)+ylab("% correct")

tgc <- summarySE(sub_table, measurevar="rt", groupvars=c("bin","win")) # "win", ,"cue"

ggplot(tgc, aes(x=bin, y=rt)) + # ,colour=cue,group=cue
  geom_point(position=pd, size=3)+
  geom_line(size=1) +
  geom_errorbar(aes(ymin=rt-se, ymax=rt+se), width=.5, position=pd) +
  ylim(0.85,1.1)+s
  facet_wrap(~win)+
  theme_bw()+
  raincloud_theme+
  scale_colour_manual(values = cbPalette)+
  scale_fill_manual(values = cbPalette)+ylab("Median Reaction Time")

### plot main effects


# tgc <- summarySE(sub_table, measurevar="corr", groupvars=c("bin"))
# 
# ggplot(tgc, aes(x=bin, y=corr),group=1) + 
#   geom_point(position=pd, size=3,group=1)+
#   geom_line(size=1,group=1) +
#   geom_errorbar(aes(ymin=corr-se, ymax=corr+se), width=.5, position=pd) +
#   ylim(0.7,0.9)+
#   #facet_wrap(~win)+
#   theme_bw()+
#   raincloud_theme+
#   scale_colour_manual(values = cbPalette)+
#   scale_fill_manual(values = cbPalette)+ylab("% correct")
# 
# tgc <- summarySE(sub_table, measurevar="rt", groupvars=c("bin"))
# 
# ggplot(tgc, aes(x=bin, y=rt)) + 
#   geom_point(position=pd, size=3,group=1)+
#   geom_line(size=1,group=1) +
#   geom_errorbar(aes(ymin=rt-se, ymax=rt+se), width=.5, position=pd) +
#   ylim(0.7,1.2)+
#   facet_wrap(~win)+
#   theme_bw()+
#   raincloud_theme+
#   scale_colour_manual(values = cbPalette)+
#   scale_fill_manual(values = cbPalette)+ylab("Median Reaction Time")