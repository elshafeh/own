clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD')
                fname_in            = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            else
                fname_in            = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            end
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_gfp                            = ft_globalmeanfield(cfg,data_pe);
            
            allsuj_data{ngrp}{sb,ncue}          = data_gfp;
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub lst_group;

cfg                     = [];
cfg.latency             = [0.5 1.2];
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;

[stat,results_summary]  = h_sens_anova(cfg,allsuj_data);

z_limit                 = [0 70];

plt_cfg                 = [];
plt_cfg.p_threshold     = 0.05;
plt_cfg.lineWidth       = 3;
plt_cfg.time_limit      = [-0.1 1.2];
plt_cfg.z_limit         = z_limit;
plt_cfg.fontSize        = 18;

subplot(3,2,1)
h_plotSingleERFstat(plt_cfg,stat{1},ft_timelockgrandaverage([],gavg_data{1,:}),ft_timelockgrandaverage([],gavg_data{2,:}));
legend({'Old','Young'})
title('Group Effect');

subplot(3,2,2)
h_plotSingleERFstat(plt_cfg,stat{2},ft_timelockgrandaverage([],gavg_data{:,1}),ft_timelockgrandaverage([],gavg_data{:,2}));
legend({'VnDT','NnDT'})
title('Cue Effect');

cfg             = [];
cfg.operation   = 'x1-x2';
cfg.parameter   = 'avg';
data1           = ft_math(cfg,gavg_data{1,1},gavg_data{1,2});
data2           = ft_math(cfg,gavg_data{2,1},gavg_data{2,2});
subplot(3,2,3)
plt_cfg.z_limit         = [-6 6];
h_plotSingleERFstat(plt_cfg,stat{3},data1,data2)
legend({'VmN.Old','VmN.Young'})
title('Interaction');
hline(0,'--k')

plt_cfg.z_limit         = z_limit;
subplot(3,2,4)
h_plotSingleERFstat(plt_cfg,stat{4},gavg_data{1,1},gavg_data{1,2});
legend({'V.Old','N.Old'})
title('VmN Old');

subplot(3,2,5)
h_plotSingleERFstat(plt_cfg,stat{5},gavg_data{2,1},gavg_data{2,2});
legend({'V.Young','N.Young'})
title('VmN Young');

clearvars -except stat

save ../data_fieldtrip/stat/new_match_ageing_summary_stat_gfp_nd.mat