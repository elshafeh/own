clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;
addpath('DrosteEffect-BrewerMap-b6a6efc/');

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

for sb = 1:21
    for ndis = 1:2
        for nevo = 1:2
            
            list_evoked                     = {'wevoked','mevoked'};
            list_dis                        = {'DIS','fDIS'};
            
            suj                             = suj_list{sb};
            fname                           = ['../../data/scnd_round/' suj '.' list_dis{ndis} '.PLF.' list_evoked{nevo} '.mat'];
            fprintf('Loading %20s\n',fname);
            load(fname);
            
            freq                            = phase_lock;
            freq                            = rmfield(freq,'rayleigh');
            freq                            = rmfield(freq,'p');
            freq                            = rmfield(freq,'sig');
            freq                            = rmfield(freq,'mask');
            
            freq.powspctrm                  = .5.*log((1+freq.powspctrm)./(1-freq.powspctrm)); % % !!
            
            cfg                             = [];
            cfg.channel                     = 1:length(freq.label);
            cfg.avgoverchan                 = 'yes';
            freq                            = ft_selectdata(cfg,freq);
            freq.label                      = {'avgPLF'};
            
            allsuj_data{sb,ndis,nevo}       = freq; clear freq phase_lock;
            
        end
    end
end

clearvars -except allsuj_data

for nevo = 1:2
    
    nsuj                    = size(allsuj_data,1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;
    
    cfg                     = [];
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'cluster';
    cfg.neighbours          = neighbours;
    
    cfg.latency             = [-0.1 0.4];
    cfg.frequency           = [5 120];
    
    cfg.clusteralpha        = 0.0000005;
    
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    stat{nevo}              = ft_freqstatistics(cfg, allsuj_data{:,1,nevo},allsuj_data{:,2,nevo});
    
end

clearvars -except allsuj_data stat

for nevo = 1:2
    
    subplot(1,2,nevo)
    
    
    [min_p{nevo},p_val{nevo}]   = h_pValSort(stat{nevo});
    stat2plot                   = h_plotStat(stat{nevo},0.00000000001,0.002);
    
    cfg                         = [];
    cfg.xlim                    = [-0.1 0.4];
    cfg.parameter               = 'powspctrm';
    
    ft_singleplotTFR(cfg,stat2plot);
    
end
