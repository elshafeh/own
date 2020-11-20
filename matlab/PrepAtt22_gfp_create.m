clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:73);

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

suj_list        = [suj_group{:}];

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    cond_main           = '';
    
    cond_sub            = {'1DIS','1fDIS'};
    
    extension_preproc   = 'bpOrder2Filt0.5t20Hz';
    
    for xcon = 1:length(cond_sub)
        
        fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{xcon} cond_main '.' extension_preproc '.pe.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        data_gfp            = ft_globalmeanfield(cfg,data_pe);
        
        fname_out           = ['../data/' suj '/field/' suj '.' cond_sub{xcon} cond_main '.' extension_preproc '.gfp.mat'];
        fprintf('Saving %s\n',fname_out);
        save(fname_out,'data_gfp','-v7.3');
        
        clear data_pe trial_choose data_gfp
        
    end
    
    clearvars -except sb suj_list
    
end