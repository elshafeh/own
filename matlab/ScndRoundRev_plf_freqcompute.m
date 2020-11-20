clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;
addpath('DrosteEffect-BrewerMap-b6a6efc/');

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

ilu                         = 0;

for sb = 1:21
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','fDIS'};
    
    for ncond = 1:length(list_cond)
        
        fname                                   = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_cond{ncond} '.mat'];
        fprintf('\nLoading %20s\n',fname);
        load(fname);
        
        tlim                                    = 2;
        f1                                      = 1;
        f2                                      = 120;
        
        cfg                                     = [];
        cfg.latency                             = [-tlim tlim];
        cfg.channel                             = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56','MLP57', ...
            'MLT14', 'MLT15', 'MRF66', 'MRF67', 'MRT13', 'MRT14', 'MRT24'};
        data_elan                               = ft_selectdata(cfg,data_elan);
        
        data_wevoked                            = data_elan ; clear data_elan fname;
        data_mevoked                            = h_removeEvoked(data_wevoked);
        
        cfg                                     = [];
        cfg.method                              = 'wavelet';
        cfg.output                              = 'fourier';
        cfg.keeptrials                          = 'yes';
        cfg.width                               = 7;
        cfg.gwidth                              = 4;
        cfg.toi                                 = -tlim:0.01:tlim;
        cfg.foi                                 = f1:f2;
        freq_wevoked                            = ft_freqanalysis(cfg, data_wevoked);
        freq_mevoked                            = ft_freqanalysis(cfg, data_mevoked);
        
        clc;
        
        cfg                                     = [];
        cfg.index                               = 'all';
        cfg.indexchan                           = 'all';
        cfg.alpha                               = 0.05;
        cfg.freq                                = [f1 f2];
        cfg.time                                = [-tlim tlim];
        
        phase_lock                              = mbon_PhaseLockingFactor(freq_wevoked, cfg);
        fname                                   = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.PLF.wevoked.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'phase_lock','-v7.3'); clear phase_lock;
        
        phase_lock                              = mbon_PhaseLockingFactor(freq_mevoked, cfg);
        fname                                   = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.PLF.mevoked.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'phase_lock','-v7.3'); clear phase_lock;
        
        clear freq_wevoked freq_mevoked
        
    end
end