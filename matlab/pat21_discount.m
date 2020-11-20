clear ; clc ; 

pos_delay = zeros(14,3);
pos_cue   = zeros(14,3);

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    load(['../data/trialinfo/' suj '.DIS.trialinfo.mat']);
    
    trialinfo(:,2)   =   trialinfo(:,1) - 2000;
    trialinfo(:,3)   =   floor(trialinfo(:,2)/100);
    trialinfo(:,4)   =   floor((trialinfo(:,2)-100*trialinfo(:,3))/10);   
    
    for dis_delay = 1:3
        pos_delay(sb,dis_delay) = length(trialinfo(trialinfo(:,4)==dis_delay,1));
    end
    
    for dis_cue = 1:3
        pos_cue(sb,dis_cue) = length(trialinfo(trialinfo(:,3)==dis_cue-1,1));
    end
    
end

subplot(1,2,1)
boxplot(pos_delay,'Labels',{'D1','D2','D3'})
title('Per Delay');ylim([50 90])
set(gca,'fontsize',18)
subplot(1,2,2)
boxplot(pos_cue,'Labels',{'U','L','R'})
title('Per Cue');ylim([50 90])
set(gca,'fontsize',18)