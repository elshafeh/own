clear ; clc ; 

addpath('../scripts.m');

[~,allsuj,~]    = xlsread('../documents/PrepAtt2_AgeDemographic.xlsx','A:E');

med_rt  = [];
pr_cor  = [];

for sb = 2:length(allsuj)
    
    [x1,~,x2]       =   h_behav_eval(allsuj{sb},0:2,0,1:4); clc ;
    
    [unf_rt,~,~]    =   h_behav_eval(allsuj{sb},0,0,1:4); clc ;
    [inf_rt,~,~]    =   h_behav_eval(allsuj{sb},[1 2],0,1:4); clc ;
    
    [d0_rt,~,~]     =   h_behav_eval(allsuj{sb},1:2,0,1:4); clc ;
    [d1_rt,~,~]     =   h_behav_eval(allsuj{sb},1:2,1,1:4); clc ;
    [d2_rt,~,~]     =   h_behav_eval(allsuj{sb},1:2,2,1:4); clc ;
    
    
    med_rt          = [med_rt;x1 unf_rt-inf_rt  d0_rt-d1_rt d2_rt-d1_rt];
    pr_cor          = [pr_cor;x2];
    
end

final               = [med_rt pr_cor];