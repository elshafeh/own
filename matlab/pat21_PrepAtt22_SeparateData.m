clear ; clc ; dleiftrip_addpath ;

for sb = 1
    
    suj_list                    = [1:4 8:17];
    suj                         = ['yc' num2str(suj_list(sb))];
    
    fprintf('Loading\n');
    
    data_file                   = ['../data/pe/' suj '.CnD.RamaBigCov.Auditory'];
    
    load([data_file '.mat'])
    
    for n = 1:length(virtsens.trial)
        
        cfg                         = [];
        cfg.trials                  = n;
        virtsens_slct               = ft_selectdata(cfg,virtsens);
        
        fprintf('Saving\n');
        
        save([data_file '.trial.' num2str(n) '.mat'],'virtsens_slct','-v7.3');
        
    end    
    
end