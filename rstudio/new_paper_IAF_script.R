library(car);library(ggplot2)
library(dae);library(nlme);library(effects);library(psych)
library(interplot);library(plyr);library(devtools)
library(ez);library(Rmisc);library(wesanderson);library(lme4);library(lsmeans)
library(plotly)
library(ggplot2)
library(ggpubr)

rm(list=ls())

# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/#palettes-color-brewer
# The palette with grey:
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette2 <- c("#E69F00", "#56B4E9", "#F0E442")
cbPalette <- c("#009E73","#0072B2", "#D55E00")

ext1           <- "~/GoogleDrive/PhD/Fieldtripping/documents/4R/"
ext2           <- "new_paper_yc_iaf_p600p1000_1Cue_two_occ.txt"
pat            <-  read.table(paste0(ext1,ext2),header=T)

model.pat      <- lme4::lmer(IAF ~ (HEMI+MOD)^2 + (1|SUB), data =pat)
model_anova    <- Anova(model.pat,type=2,test.statistic=c("F"))
print(model_anova)

lsmeans(model.pat,  "MOD",details= TRUE)

b <- ezANOVA(pat,dv=.(IAF),wid = .(SUB),within = .(HEMI,MOD),detailed=T)
print(b)
# n2 = nom / [nom+dom]


tgc <- summarySE(pat, measurevar="IAF", groupvars=c("MOD"))

ggplot(pat, aes(x = MOD, y = IAF)) +
  geom_boxplot(alpha=0.7) +
  scale_y_continuous(limits=c(6, 16)) +
  scale_x_discrete(name = "") +
  ggtitle("") +
  theme_bw() +
  theme(plot.title = element_text(size = 14, family = "Tahoma", face = "bold"),
        text = element_text(size = 12, family = "Tahoma"),
        axis.title = element_text(face="bold"),
        axis.text.x=element_text(size = 11)) +
  scale_fill_brewer(palette = "Accent")+theme_classic()

# ggplot2::ggplot(tgc, aes(x=MOD, y=IAF, fill=HEMI)) +
#   geom_bar(position=position_dodge(), stat="identity") +
#   geom_errorbar(aes(ymin=IAF-se, ymax=IAF+se),width=.4,position=position_dodge(.9))+
#   ylim(0,15)+scale_fill_manual(values=cbPalette)

# p2 <- ggplot2::ggplot(pat, aes(x=CHAN, y=IAF, fill=CUE_ORIG)) + 
#   geom_boxplot()+ylim(5,20)+scale_fill_manual(values=cbPalette)
# 
# p1 <- ggplot2::ggplot(pat, aes(x=CHAN, y=IAF,fill=CHAN)) + 
#   geom_boxplot()+ylim(5,20)+scale_fill_manual(values=cbPalette2)
# 
# ggarrange(p1, p2,ncol = 2, nrow = 1)