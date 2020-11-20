clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list            = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(sb))] ;
    
    for cond_main           = {'CnD.prep21.AV.1t20Hz.m800p2000msCov'}
        
        fname               = ['../data/paper_data/' suj '.' cond_main{:} '.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        list_cue                = {'N','L','R'};
        list_ix_cue             = {0,1,2};
        list_ix_tar             = {1:4,1:4,1:4};
        
        for ncue = 1:length(list_cue)
            
            cfg                 = [];
            cfg.trials          = h_chooseTrial(virtsens,list_ix_cue{ncue},0,list_ix_tar{ncue});
            sub_virtsens        = ft_selectdata(cfg,virtsens);
            
            sub_virtsens        = h_removeEvoked(sub_virtsens);
            
            cfg                 = [];
            cfg.channel         = 4;
            cfg.output          = 'fourier';
            cfg.method          = 'mtmconvol';
            cfg.taper           = 'hanning';
            cfg.foi             = 1:1:20;
            cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
            cfg.toi             = -3:.05:3;
            cfg.keeptrials      = 'yes';
            freq                = ft_freqanalysis(cfg,sub_virtsens);
            
            cfg                 = [];
            cfg.index           = 'all';
            cfg.indexchan       = 'all';
            cfg.alpha           = 0.05;
            cfg.freq            = [1 20];
            cfg.time            = [-3 3];
            phase_lock          = mbon_PhaseLockingFactor(freq, cfg);
            
            save(['../data/paper_data/' suj '.' list_cue{ncue} cond_main{:} '.MinEvoked.PhaseLockingValueAndFreq.mat'],'phase_lock','freq');
            
            clc ;
            
        end
        
    end
end