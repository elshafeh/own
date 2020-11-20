suj_list   ={'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    load(['../data/paper_data/' suj '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.mat']);
    
    trial_info      = virtsens.trialinfo;
    
    save(['../data/paper_data/' suj '.CnD.trialinfo.mat'],'trial_info'); 
    
    clear trial_info
    
end