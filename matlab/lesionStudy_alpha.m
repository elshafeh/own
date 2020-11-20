clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

patient_list;

suj_group{1}                                = fp_list_meg ;
suj_group{2}                                = cn_list_meg ; clear *list* ;

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                                 = suj_list{sb};
        cond_main                           = 'CnD';
        
        list_cue                            = {''};
        
        for ncue = 1:length(list_cue)
            
            ext_name                        = 'waveletPOW.1t150Hz.m3000p3000.AvgTrials.mat';
            
            fname_in                        = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_cue{ncue} cond_main '.' ext_name];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                             = [];
            cfg.baseline                    = [-0.6 -0.2];
            cfg.baselinetype                = 'relchange';
            freq                            = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngrp}{sb,ncue}      = freq; clear tmp ;
        end
        
        clear freq
        
    end
end

clearvars -except allsuj_data ; clc ;

[~,neighbours]                      = h_create_design_neighbours(length(allsuj_data{1}),allsuj_data{1}{1},'meg','t'); clc;
nsubj                               = size(allsuj_data{1},1);

cfg                                 = [];

cfg.latency                         = [-0.2 1.2];
cfg.frequency                       = [7 15];

cfg.statistic                       = 'indepsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05; 
cfg.clusterstatistic                = 'maxsum';
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.neighbours                      = neighbours;
cfg.design                          = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.ivar                            = 1;
cfg.minnbchan                       = 3; % !!

for ncue = 1:size(allsuj_data{1},2)
    stat{ncue}                      = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue}); % young minus control
    [min_p(ncue), p_val{ncue}]      = h_pValSort(stat{ncue}) ;
end

for ncue = 1:length(stat)
    
    zlimit                          = 0.5;
    plimit                          = 0.2;
    stat2plot                       = h_plotStat(stat{ncue},0.00001,plimit);
    
    cfg                             = [];
    cfg.layout                      = 'CTF275.lay';
    cfg.zlim                        = [-zlimit zlimit];
    cfg.marker                      = 'off';
    cfg.comment                     = 'no';
    ft_topoplotER(cfg,stat2plot);
    
end