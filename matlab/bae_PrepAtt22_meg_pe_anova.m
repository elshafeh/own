clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

suj_group{1}    = allsuj(2:end,1);
suj_group{2}    = allsuj(2:end,2);

lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD')
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

[~,neighbours]          = h_create_design_neighbours(14,allsuj_data{1}{1},'meg','t');

cfg.neighbours          = neighbours;
cfg.minnbchan           = 2;

[stat,results_summary]  = h_sens_anova(cfg,allsuj_data);

for ntest = 1:length(stat)
    stat_to_plot{ntest} = h_plotStat(stat{ntest},0.000000000000001,0.05);
end

cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.zlim    = [-3 3];
cfg.marker  = 'off';
cfg.comment = 'no';

for ntest = 1:length(stat)
    subplot(1,5,ntest)
    ft_topoplotER(cfg,stat_to_plot{ntest})
    title(results_summary{ntest});
end
