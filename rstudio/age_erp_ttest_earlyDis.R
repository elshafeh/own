## -- DISTRACTOR : subtract fake ; baseline then gfp (early)

rm(list=ls())
ext1        <- "/Users/heshamelshafei/Dropbox/project_me/pub/Papers/phd/paper_age_erp/_prep/doc/"
ext2        <- "4R_age_erp_pe2R_1DIS"
pat         <- read.table(paste0(ext1,ext2,'.txt'),header=T)


sub_pat     <- pat[pat$CHANNEL=="Cz.10" & pat$TIME=="1p40p80",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="Cz.10" & pat$TIME=="2p80p130",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="Cz.10" & pat$TIME=="3p200p250",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="Pz.5" & pat$TIME=="4p290p340",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="Fz.15" & pat$TIME=="4p290p340",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="Fz.15" & pat$TIME=="5p350p500",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)



# -- MEG

sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="1p40p80",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18

cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="2p80p130",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="3p200p250",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="4p290p340",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)

sub_pat     <- pat[pat$CHANNEL=="gmfp" & pat$TIME=="5p350p500",c("GROUP","AVG")]
res         <- t.test(AVG ~ GROUP, data = sub_pat, var.equal = TRUE)
res$p.value * 18
cohen.d(sub_pat,"GROUP",alpha=.05)


# -- EEG
# 1p40p80 2p80p130 3p200p250 4p290p340 5p350p500

# sub_pat     <- pat[pat$CHANNEL=="gmfp",]
# ggplot(sub_pat, aes(x=TIME, y=AVG, fill=GROUP)) +
#   geom_boxplot()+ylim(0,200)
# 
# 
# sub_pat     <- pat[pat$CHANNEL=="Cz.10",]
# sub_pat     <- sub_pat[sub_pat$TIME=="1p40p80" | sub_pat$TIME=="2p80p130" | sub_pat$TIME=="3p200p250",]
# 
# ggplot(sub_pat, aes(x=TIME, y=AVG, fill=GROUP)) +
#   geom_boxplot()+ylim(-20,20)
# 
# sub_pat     <- pat[pat$CHANNEL=="Pz.5",]
# sub_pat     <- sub_pat[sub_pat$TIME=="1p40p80" | sub_pat$TIME=="4p290p340",]
# 
# ggplot(sub_pat, aes(x=TIME, y=AVG, fill=GROUP)) +
#   geom_boxplot()+ylim(-20,20)
# 
# 
# sub_pat     <- pat[pat$CHANNEL=="Fz.15",]
# sub_pat     <- sub_pat[sub_pat$TIME=="5p350p500" | sub_pat$TIME=="4p290p340",]
# 
# ggplot(sub_pat, aes(x=TIME, y=AVG, fill=GROUP)) +
#   geom_boxplot()+ylim(-20,20)