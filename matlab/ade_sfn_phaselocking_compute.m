clear ; clc; close all;

[file,path]                                         = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

i                                                   = 0;

for nm = 1:length(list_modality)
    
    list_suj                                            = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                             = list_suj{ns};
        modality                                        = list_modality{nm};
        
        fprintf('handling mod %2d out-of %2d || sub %2d out-of %d\n\n', ...
            nm,length(list_modality),ns,length(list_suj));
        
        dir_data                                        = ['../data/' suj '/preprocessed/'];
        fname                                           = [dir_data suj '_secondreject_postica_' modality '.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        load(['../data/' suj '/erf/' suj '_sfn.erf_' modality '_maxchan.mat']);
        
        cfg                                             = [];
        cfg.latency                                     = [-0.5 0]; % this needs to be put in the filename
        cfg.trials                                      = find(secondreject_postica.trialinfo(:,3) == 1);
        cfg.channel                                     = max_chan;
        prestim_data                                    = ft_selectdata(cfg, secondreject_postica); % select corresponding data
        
        all_rt                                          = [[1:length(prestim_data.trialinfo)]'  prestim_data.trialinfo(:,8)];
        all_rt                                          = sortrows(all_rt,2);
        
        nb_bin                                          = 6;
        bin_size                                        = floor(length(all_rt)/nb_bin);
        
        for nb = 1:nb_bin
            
            cfg                                         = [] ;
            cfg.output                                  = 'fourier';
            cfg.method                                  = 'mtmfft';
            cfg.keeptrials                              = 'yes';
            cfg.pad                                     = 3 ;
            
            lm1                                         = 1+bin_size*(nb-1);
            lm2                                         = bin_size*nb;
            
            cfg.trials                                  = all_rt(lm1:lm2,1);
            
            cfg.foi                                     = 1:1/cfg.pad:25;
            cfg.taper                                   = 'hanning';
            cfg.tapsmofrq                               = 0 ;
            freq                                        = ft_freqanalysis(cfg,prestim_data);
            
            cfg                                         = [];
            cfg.indexchan                               = 'all';
            cfg.index                                   = 'all';
            cfg.alpha                                   = 0.05;
            cfg.time                                    = [-1 6];
            cfg.freq                                    = [freq.freq(1) freq.freq(end)];
            
            phase_lock{nb}                              = mbon_PhaseLockingFactor(freq, cfg);
            phase_lock{nb}.rt                           = median(all_rt(lm1:lm2,2));
            
        end
        
        fname                                           = ['../data/' suj '/tf/' suj '_sfn.phaselock_' modality '.mat'];
        save(fname,'phase_lock','-v7.3');
        
        clear phase_lock;
        
    end
end