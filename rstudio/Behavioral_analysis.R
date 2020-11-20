library(ez)
library(car)
rm(list=ls())
options(digits=9)
suj_list = c("yc1","yc2","yc3","yc4","yc5","yc6","yc7","yc8","yc9","yc10","yc11","yc12","yc13","yc14","yc15","yc16",
             "yc17","yc18","yc19","yc20","yc21")

pos_concat <- data.frame(ticker=character(), value=numeric(), date = as.Date(character()),stringsAsFactors=FALSE)

# Load and Recode

for (sb in 1:length(suj_list)) {
  
  suj   = suj_list[sb]
  fname = paste0("/Users/heshamelshafei/Dropbox/Fieldtripping/R/new_pos/",suj, ".pat2.raw.pos",collapse = NULL);
  pos   = read.table(fname,header=F)
  pos   = cbind.data.frame(rep_len(suj,lengths(pos)[1]),rep_len(substr(suj, 1, 1),lengths(pos)[1]),pos[,2],pos[,2],pos[,1])
  names(pos) <- c("subject","group", "code","new_code","sample")
  
  pos   = pos[pos$code != 90 & pos$code != 253 & pos$code != 10 & pos$code != 91,]
  
  pos[pos$code < 54 & pos$code > 50,4] = (2000) + (pos[pos$code < 54 & pos$code > 50,3])-50
  pos[pos$code == 251 | pos$code == 252,4] = (9000) + (pos[pos$code == 251 | pos$code == 252,3])-250
  pos[pos$code < 65 & pos$code > 60,4] = (3000) + (pos[pos$code < 65 & pos$code > 60,3])-60
  pos[pos$code < 35 & pos$code > 0,4] = 1000 +  (pos[pos$code < 35 & pos$code > 0,3])
  pos[pos$code < 235 & pos$code > 100 ,4] = 1000 +  (pos[pos$code < 235 & pos$code > 100 ,3])
  
  pos_concat = rbind(pos_concat,pos)
  
}

rm(list=setdiff(ls(), "pos_concat"))

behav_summary <- data.frame(ticker=character(), value=numeric(), date = as.Date(character()),stringsAsFactors=FALSE)
ntrl = 0;

pos_concat1 <- data.frame(lapply(pos_concat[,3:5], as.numeric), stringsAsFactors=FALSE)
pos_concat2 <- data.frame(lapply(pos_concat[,1:2], as.character), stringsAsFactors=FALSE)
pos_concat  = cbind.data.frame(pos_concat2,pos_concat1)

for (n in 1:lengths(pos_concat)[1]) {
  
  if (floor(pos_concat$new_code[n]/1000) == 1) {
    
    suj    = pos_concat$subject[n]
    group  = pos_concat$group[n]
    code   = pos_concat$new_code[n]-1000
    cue    = floor(code/100)
    dis    = floor((code-100*cue)/10)
    tar    = code %% 10
    
    if (tar>2) {
      xp=2
    } else {
      xp=1
    }
    
    fcue=1; p=1;
    
    while (fcue==1 & n+p <=lengths(pos_concat)[1]) {
      acc_width = pos_concat$sample[n+p] - pos_concat$sample[n];
      acc_width  = acc_width * 5/3;
      
      if (floor(pos_concat$new_code[n+p]/1000)!=1 & pos_concat$sample[n+p] > pos_concat$sample[n+p-1] & acc_width<5000){
        p=p+1}
      else {
        fcue=2
      }
    }
    
    p = p - 1;
    
    subset = pos_concat[seq(from = n, to = n+p, by = 1),]
    
    cuetmp = which(floor(subset$new_code/1000) %in% 1)
    distmp = which(floor(subset$new_code/1000) %in% 2)
    tartmp = which(floor(subset$new_code/1000) %in% 3)
    reptmp = which(floor(subset$new_code/1000) %in% 9)
    
    cueOn  = subset$sample[cuetmp]
    
    if(length(tartmp)==0){type="bad";rep=0}
    else{
      if(length(reptmp)==0){type="miss";rep=0}
      else if(length(reptmp)==1){
        if(reptmp[1] < tartmp){type="fa";rep=0}
        else{
          rep = subset$new_code[reptmp] - 9000
          if(rep == xp){type="correct"}
          else {type="incorrect"}
        }
      }
      else{
        if(reptmp[1] < tartmp){type="fa";rep=0}
        else {type="mr";rep=0}
      }
    }
    
    cueOn  = subset$sample[cuetmp]
    
    if (dis == 0){
      disOn = 0
      DT    = 0
      CD    = 0
      
    } else {
      disOn  = subset$sample[distmp]
      CD     = (disOn - cueOn) * 5/3
      tarOn  = subset$sample[tartmp]
      DT     = (tarOn - disOn) * 5/3
    }
    
    tarOn  = subset$sample[tartmp]
    repOn  = subset$sample[reptmp[1]]
    
    RT     = (repOn - tarOn) * 5/3
    CT     = (tarOn - cueOn) * 5/3
    
    trialinfo     = cbind(suj,group,code,cue,dis,tar,xp,type,cueOn,disOn,tarOn,repOn,CT,CD,DT,RT)
    behav_summary = rbind(behav_summary,trialinfo)
    
    rm(suj,group,code,cue,dis,tar,xp,type,cueOn,disOn,tarOn,repOn,CT,CD,DT,RT)
    
  }
  
}

rm(list=setdiff(ls(), "behav_summary"))

list_groups = c("y","o")

par(mfrow=c(2,1))

for (g in 1){
  
  ct  <- behav_summary[behav_summary$group==list_groups[g],13]
  ct_plot   <- as.numeric(levels(ct))[ct]
  hist(ct_plot, 
       xlab="MilliSeconds", 
       border="red", 
       xlim=c(1150,1250),
       ylim = c(0,0.8),
       col="blue", 
       las=1, 
       breaks=5, 
       prob = TRUE)
}