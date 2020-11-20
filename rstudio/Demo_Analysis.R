library(ggplot2)

rm(list=ls())
ext1  = "/Users/heshamelshafei/Dropbox/Fieldtripping/R/txt/";
ext2  = "DemoSummary.txt";
fname = paste0(ext1,ext2, collapse = NULL);
pat   = read.table(fname,header=T)

names(pat) <- factor(c("SUB","GROUP","SEX","LAT","AGE","EDUCATION","MUSIC"))

pat_yc <- pat[pat$GROUP == "Young",]
pat_oc <- pat[pat$GROUP == "Old",]

a <- t.test(pat_yc$AGE,pat_oc$AGE);print(a)
b <- t.test(pat_yc$MUSIC,pat_oc$MUSIC);print(b)
c <- t.test(pat_yc$EDUCATION,pat_oc$EDUCATION);print(c)

par(mfrow=c(1,3))
theme = theme_set(theme_minimal())
theme = theme_update(legend.position="right", 
                     legend.title=element_blank(), 
                     panel.grid.major.x=element_blank(),
                     text = element_text(size=16))

ggplot(pat, aes(x=GROUP, y=AGE, color=GROUP)) + 
  geom_boxplot() + coord_cartesian(xlim=NULL,ylim=c(10, 80))

ggplot(pat, aes(x=GROUP, y=EDUCATION, color=GROUP)) + 
  geom_boxplot()+coord_cartesian(xlim=NULL,ylim=c(10, 25))

ggplot(pat, aes(x=GROUP, y=MUSIC, color=GROUP)) + 
  geom_boxplot()+coord_cartesian(xlim=NULL,ylim=c(0, 15))

ggplot(pat, aes(x=GROUP, y=SEX, color=GROUP)) + 
  geom_boxplot()

# boxplot(cbind(pat_yc$Age,pat_oc$Age),names=c("Young","Old"),ylab = "Age"
#         ,ylim=c(10,80),col=c('green','red'))
# boxplot(cbind(pat_yc$Edu,pat_oc$Edu),names=c("Young","Old"),ylab = "Education",ylim=c(10,25))
# boxplot(cbind(pat_yc$Music,pat_oc$Music),names=c("Young","Old"),ylab = "Music",ylim=c(0,15))