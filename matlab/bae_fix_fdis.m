clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% 
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:73);

% suj_list            = [suj_group{1};suj_group{2};suj_group{3}];
% suj_list            = unique(suj_list);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    for cond_main           = {'fDIS'}
        
        fname_in            = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        trial_choose = [];
        trial_origin = length(data_elan.time);
        
        for ntrl = 1:length(data_elan.time)
        
            x = length(data_elan.time{ntrl});
            y = length(data_elan.trial{ntrl});
            
            if x == y && x == 4800
               
                trial_choose = [trial_choose; ntrl];
                
            end
            
            clear x y
            
        end
        
        clear ntrl
        
        if length(trial_choose) ~= trial_origin
           
            cfg             = [];
            cfg.trials      = trial_choose;
            data_elan       = ft_selectdata(cfg,data_elan);
            
            fname_out       = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
            
            fprintf('Saving %s\n',fname_out);
            
            save(fname_out,'data_elan','-v7.3');
            
        end 
        
        clear data_elan trial_* fname_*
        
    end
    
    clear suj
    
end