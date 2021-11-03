# rel visual
# find_outlier          <- alldata[alldata$eyes == "open" &
#                                    alldata$val < -0.5,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# alldata$sub           <- factor(alldata$sub)


# Lat index
# bad_suj <- c("sub039")
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# 
# find_outlier          <- alldata[alldata$behavior == "correct_e" &
#                                    alldata$eyes == "open" &
#                                    alldata$val < -0.18,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }
# 
# find_outlier          <- alldata[alldata$behavior == "fast" &
#                                    alldata$eyes == "open" &
#                                    alldata$val < -0.18,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }

# find_outlier          <- alldata[alldata$behavior == "fast" &
#                                    alldata$eyes == "closed" &
#                                    alldata$val > 0.6,]
# find_outlier$sub      = factor(find_outlier$sub)
# bad_suj <- as.character(unique(find_outlier$sub))
# for (nbad in 1:length(bad_suj)){
#   alldata <- alldata[alldata$sub != bad_suj[nbad],]
# }