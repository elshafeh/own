clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

patient_list ;
suj_group{1}    = fp_list_meg;
suj_group{2}    = cn_list_meg;

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        cond_main       = {'1DIS','1fDIS'};
        
        for dis_type = 1:2
            
            fname_in                            = ['../data/' suj '/field/' suj '.' cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            %             tmp_gfp{dis_type}                   = data_gfp;
            tmp_pe{dis_type}                    = data_pe;
            
            clear data_pe data_gfp
            
        end
        
        avg_diff                                = tmp_pe{1};
        avg_diff.avg                            = tmp_pe{1}.avg - tmp_pe{2}.avg ; clear tmp 
        
        cfg                                     = [];
        cfg.baseline                            = [-0.1 0];
        avg_diff_lb                             = ft_timelockbaseline(cfg,avg_diff);
        
        cfg                                     = [];
        cfg.method                              = 'amplitude';
        avg_diff_lb_gfp                         = ft_globalmeanfield(cfg,avg_diff_lb);
        
        allsuj_data{ngrp}{sb}                   = avg_diff_lb_gfp;
        
        clear avg_diff avg_gfp
        
    end
    
    gavg_data{ngrp}         = ft_timelockgrandaverage([],allsuj_data{ngrp}{:});
    
end

clearvars -except *_data ; clc ;

nbsuj                   = length(allsuj_data{1});

[~,neighbours]          =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');

test_latency            = [-0.1 0.65];

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
cfg.p_threshold        = 0.2;
cfg.lineWidth          = 2;
cfg.fontSize           = 20;
cfg.time_limit         = [-0.1 0.7];
cfg.z_limit            = [0 120];
cfg.legend             = {'Old','Young'};
h_plotSingleERFstat(cfg,stat,gavg_data{1},gavg_data{2});
legend({'Fpatient','Fcontrol'})