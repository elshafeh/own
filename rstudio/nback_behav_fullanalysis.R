## Header ##
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
library(viridis)
library(corrplot)
library(Hmisc)
library(PerformanceAnalytics)

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

## Run anova
pd          <- position_dodge(0.1)

fname       <- "M:/github/me/data/txt/nback_behav_data_4anova.csv"
sub_table   <- read.table(fname,sep = ',',header=T)

model1.pat  <- lme4::lmer(rt ~ cond + (1|suj), data =sub_table)
model2.pat  <- lme4::lmer(correct ~ cond + (1|suj), data =sub_table)

model_anova1  <- Anova(model1.pat,type=2,test.statistic=c("F"))
model_anova2  <- Anova(model2.pat,type=2,test.statistic=c("F"))

print(model_anova1)
print(model_anova2)

summary(as.glht(update(pairs(emmeans(model1.pat, "cond")), by = NULL)))
summary(as.glht(update(pairs(emmeans(model2.pat, "cond")), by = NULL)))

sumld <- sub_table %>% 
  select(-suj) %>% 
  group_by(cond) %>% 
  summarise_all(funs(mean, median, lower = lb, upper = ub))


cbPalette <- c("#CC79A7","#009E73","#0072B2")

p1<-  ggplot(data = sub_table, 
             aes(x = cond, y = rt, fill = cond)) +
  geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
  geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5)+
  guides(fill = FALSE) +
  guides(color = FALSE) +
  theme_bw()+
  ylim(c(200,1000))+
  raincloud_theme+
  scale_colour_manual(values = cbPalette)+
  scale_fill_manual(values = cbPalette)

p2<-  ggplot(data = sub_table, 
             aes(x = cond, y = incorrect, fill = cond)) +
  geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
  geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5)+
  guides(fill = FALSE) +
  guides(color = FALSE) +
  theme_bw()+ 
  ylim(c(0,0.15))+
  raincloud_theme+
  scale_colour_manual(values = cbPalette)+
  scale_fill_manual(values = cbPalette)
  
ggarrange(p1,p2,ncol=1,nrow=2)
