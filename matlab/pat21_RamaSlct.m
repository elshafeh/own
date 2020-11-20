clear ; clc ; close all ; dleiftrip_addpath ;

for sub = 1:14
    
    suj_list    = [1:4 8:17];
    
    suj         = ['yc' num2str(suj_list(sub))];
    
    cnd_list    = {'CnD.Rama1t20HzCov','CnD.Rama50t140HzCov'};
    
    for ncnd = 1:2
        
        fname   = ['../data/all_data/' suj '.' cnd_list{ncnd} '.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        big_virtsens = virtsens ; clear virtsens ;
        
        load ../data/yctot/RamaTriaList.mat
        
        lst_cnd_cue = {''};%{'N','L','R'};
        
        for ncue = 1:length(lst_cnd_cue)
            
            cfg                     = [];
            
            if isempty(lst_cnd_cue{ncue})
                cfg.trials              = [trial_list{sub,:}];
            else
                cfg.trials              = [trial_list{sub,ncue}];
            end
            
            cfg.channel             = [1 2 10];
            virtsens                = ft_selectdata(cfg,big_virtsens);
            virtsens                = rmfield(virtsens,'cfg');
            
            fname                   = ['../data/all_data/' suj '.' lst_cnd_cue{ncue} cnd_list{ncnd} 'AudRIPS.mat'];
            
            fprintf('Saving %30s\n',fname);
            save(fname,'virtsens','-v7.3');
            
            clear virtsens fname;
            
        end
        
    end
end