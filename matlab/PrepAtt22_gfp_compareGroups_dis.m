clear ; clc ; 

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]            = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}            = allsuj(2:15,1);
suj_group{2}            = allsuj(2:15,2);

lst_group               = {'Old','Young'}; 

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        cond_main       = {'DIS','fDIS'};
        
        for dis_type = 1:2
            
            dir_data                            = '~/GoogleDrive/NeuroProj/Publications/Papers/paper_age_erp/_prep/data/';
            fname_in                            = [dir_data suj '.' cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            tmptmp{dis_type}                    = data_pe;
            
            
            clear data_pe data_gfp
            
        end
        
        pe_diff                                 = tmptmp{1};
        pe_diff.avg                             = tmptmp{1}.avg - tmptmp{2}.avg;
        
        cfg                                     = [];
        cfg.baseline                            = [-0.1 0];
        pe_diff                                 = ft_timelockbaseline(cfg,pe_diff);
        
        cfg                                     = [];
        cfg.method                              = 'amplitude';
        data_gfp                                = ft_globalmeanfield(cfg,pe_diff);
        
        allsuj_data{ngrp}{sb}                   = data_gfp;

        
    end
    
    gavg_data{ngrp}                             = ft_timelockgrandaverage([],allsuj_data{ngrp}{:});
    
end

clearvars -except *_data ; clc ;

nbsuj                   = 14;
[~,neighbours]          =  h_create_design_neighbours(14,allsuj_data{1}{1},'gfp','t');
test_latency            = [0 0.35];

cfg                     = [];
cfg.latency             = test_latency;
cfg.statistic           = 'indepsamplesT';
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                = 1;
stat                    = ft_timelockstatistics(cfg, allsuj_data{1}{:}, allsuj_data{2}{:});

[min_p,p_val]           = h_pValSort(stat) ;

cfg                    = [];
cfg.p_threshold        = 0.05;
cfg.lineWidth          = 4;
cfg.fontSize           = 20;
cfg.time_limit         = [-0.1 0.35];
cfg.z_limit            = [0 150];
cfg.legend             = {'Old','Young'};
h_plotSingleERFstat(cfg,stat,gavg_data{1},gavg_data{2});
legend({'Aged','young'})
set(gca,'fontsize', 18)