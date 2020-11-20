clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

for sb = 1:21
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','fDIS'};
    
    for ncond = 1:length(list_cond)
        
        fname               = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.AudTPFC.1t120Hz.m200p800msCov.mat'];
        
        fprintf('\nLoading %20s\n',fname); load(fname);
        
        cfg                 = [];
        cfg.latency         = [0.1 0.3];
        data                = ft_selectdata(cfg,virtsens);
        
        cfg                 = [];
        cfg.order           = 5;
        cfg.method          = 'bsmart';
        mdata               = ft_mvaranalysis(cfg, data);
        
        cfg                 = [];
        cfg.method          = 'mvar';
        mfreq               = ft_freqanalysis(cfg, mdata);
        
        cfg                 = [];
        cfg.method          = 'granger';
        mgranger            = ft_connectivityanalysis(cfg, mfreq);
        
        for vribles = {'mgranger'}
            
            fname_out           = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.AudTPFC.1t120Hz.m200p800msCov.' vribles{:} '.mat'];
            fprintf('Saving %50s\n',fname_out);
            save(fname_out,vribles{:},'-v7.3')
            
        end
        
        clear pdc mpdc data mdata freq mfreq virtsens;
        
    end
end
