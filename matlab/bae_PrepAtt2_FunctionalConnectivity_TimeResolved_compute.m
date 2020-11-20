clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
suj_list     = suj_group{1};

clearvars -except *suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cond_main           = 'CnD';
    fname_in            = ['../data/' suj '/field/' suj '.' cond_main '.Rama.1t20Hz.m800p2000msCov.waveletFOURIER.1t19Hz.m3000p3000.KeepTrials.mat'];
    
    fprintf('\nLoading %50s \n\n',fname_in);
    
    load(fname_in)
   
    list_ix_cond       = {'','R','L','NL','NR'};
    list_ix_cue        = {0:2,2,1,0,0};
    list_ix_tar        = {1:4,[2 4],[1 3],[1 3],[2 4]};
    list_ix_dis        = {0,0,0,0,0};
    
    for cnd = 1:length(list_ix_cond)
        
        cfg                     = [];
        cfg.latency             = [-1 2];
        cfg.frequency           = [5 15];
        cfg.channel             = [5:9 40 41 76:79];
        cfg.trials              = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
        new_freq                = ft_selectdata(cfg,freq);
        
        name_ext_freq           = [num2str(cfg.frequency(1)) 't' num2str(cfg.frequency(2)) 'Hz'];
        name_ext_time           = ['m' num2str(abs(cfg.latency(1))*1000) 'p' num2str(abs(cfg.latency(end))*1000) 'ms'];

        cfg                     = [];
        cfg.method              = 'plv';
        freq_plv                = ft_connectivityanalysis(cfg, new_freq);
        
        freq_plv.powspctrm      = freq_plv.plvspctrm;
        freq_plv                = rmfield(freq_plv,'plvspctrm');
        
        fname_out               = ['../data/' suj '/field/' suj '.' list_ix_cond{cnd} cond_main '.' name_ext_freq '.' name_ext_time '.FeFAudIPSACC.plv.mat'];
        
        fprintf('\nSaving %50s \n\n',fname_out);
        
        save(fname_out,'freq_plv','-v7.3');
        
        clear freq_*
        
    end
    
end
