clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

list_measure    = {'cohimag','wpli_debiased'};
list_cue        = {'RCnD','LCnD','NCnD'};
list_time       = {'m600m200','p600p1000'};

for ncue = 1:length(list_cue)
    
    suj_list            = [1:4 8:17] ;
    
    for sb = 1:length(suj_list)
        
        suj             = ['yc' num2str(suj_list(sb))] ;
        
        for ntime = 1:length(list_time)
            
            fname       = ['../data/conn/' suj '.' list_cue{ncue} '.PaperAudVisTD.1t20Hz.m800p2000msCov.granger.' list_time{ntime} '.mat'];
            load(fname);
            fprintf('Loading %s\n',fname);
            
            freq            = h_grang2freq(freq_con);
            
            data_mat        = freq.powspctrm;
            data_matZ       = .5.*log((1+data_mat)./(1-data_mat));
            
            tmp{ntime}      = data_matZ; clear data_matZ data_mat;
            
        end
        
        allsuj_data{sb,ncue}               = freq; clear freq;
        allsuj_data{sb,ncue}.powspctrm     = (tmp{2}-tmp{1}); clear tmp;
        
    end
end

clearvars -except allsuj_data list_*;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];
cfg.neighbours          = neighbours;
cfg.frequency           = [5 15];
cfg.minnbchan           = 0;
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

list_compare            = [1 2; 1 3; 2 3];

istat                   = 0;
list_test               = {};

for ntest = 1:size(list_compare,1)
    
    istat               = istat + 1;
    
    ix1                 = list_compare(ntest,1);
    ix2                 = list_compare(ntest,2);
    
    stat{istat}         = ft_freqstatistics(cfg,allsuj_data{:,ix1}, allsuj_data{:,ix2});
    list_test{istat}    = [list_cue{ix1} ' ' list_cue{ix2}];
    
end

for istat = 1:length(stat)
    [list_min_p(istat),list_p_val{istat}]   = h_pValSort(stat{istat});  
end

for istat = 1:length(stat)
    
    p_limit         = 0.2;
    
    if list_min_p(istat) < p_limit
        figure;
        
        stat2plot   = h_plotStat(stat{istat},0.0000001,p_limit);
        
        for nchan = 1:length(stat2plot.label)
            subplot(9,5,nchan)
            cfg             = [];
            cfg.ylim        = [-5 5];
            cfg.channel     = nchan;
            ft_singleplotER(cfg,stat2plot);
        end
        
    end
end
    