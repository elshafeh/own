clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

suj_group{1}    = allsuj(2:end,1);
suj_group{2}    = allsuj(2:end,2);

lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT.eeg';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD.eeg')
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            else
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            end
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            allsuj_data{ngrp}{sb,ncue}          = data_pe;
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub lst_group;

cfg                     = [];
cfg.latency             = [-0.1 0.5];
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;

[~,neighbours]          = h_create_design_neighbours(14,allsuj_data{1}{1},'gfp','t');

cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;

[stat,results_summary]  = h_sens_anova(cfg,allsuj_data);

i = 0 ;

for nchan = 1:length(stat{1}.label)
    
    z_limit                 = [-15 15];
    
    plt_cfg                 = [];
    plt_cfg.channel         = nchan;
    plt_cfg.p_threshold     = 0.05;
    plt_cfg.lineWidth       = 3;
    plt_cfg.time_limit      = [-0.1 0.6];
    plt_cfg.z_limit         = z_limit;
    plt_cfg.fontSize        = 18;
    
    i  = i + 1;
    subplot(7,5,i)
    
    h_plotSingleERFstat_selectChannel(plt_cfg,stat{1},ft_timelockgrandaverage([],gavg_data{1,:}),ft_timelockgrandaverage([],gavg_data{2,:}));
    legend({'Old','Young'})
    title(['Group Effect ' stat{1}.label{nchan}]);
    
    i  = i + 1;
    subplot(7,5,i)
    h_plotSingleERFstat_selectChannel(plt_cfg,stat{2},ft_timelockgrandaverage([],gavg_data{:,1}),ft_timelockgrandaverage([],gavg_data{:,2}));
    
    legend({'VnDT','NnDT'})
    title(['Cue Effect ' stat{1}.label{nchan}]);
    
    cfg             = [];
    cfg.operation   = 'x1-x2';
    cfg.parameter   = 'avg';
    data1           = ft_math(cfg,gavg_data{1,1},gavg_data{1,2});
    data2           = ft_math(cfg,gavg_data{2,1},gavg_data{2,2});
    
    i  = i + 1;
    subplot(7,5,i)
    plt_cfg.z_limit         = [-6 6];
    h_plotSingleERFstat_selectChannel(plt_cfg,stat{3},data1,data2)
    
    legend({'VmN.Old','VmN.Young'})
    title(['Interaction ' stat{1}.label{nchan}]);
    hline(0,'--k')
    
    plt_cfg.z_limit         = z_limit;
    
    i  = i + 1;
    subplot(7,5,i)
    
    h_plotSingleERFstat_selectChannel(plt_cfg,stat{4},gavg_data{1,1},gavg_data{1,2});
    legend({'V.Old','N.Old'})
    title(['VmN Old ' stat{1}.label{nchan}]);
    
    i  = i + 1;
    subplot(7,5,i)
    
    h_plotSingleERFstat_selectChannel(plt_cfg,stat{5},gavg_data{2,1},gavg_data{2,2});
    
    legend({'V.Young','N.Young'})
    title(['VmN Young ' stat{1}.label{nchan}]);
    
end