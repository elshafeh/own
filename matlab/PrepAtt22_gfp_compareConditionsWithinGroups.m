clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
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
        
        cfg                                     = [];
        cfg.parameter                           = 'avg';
        cfg.operation                           = 'x1-x2';
        allsuj_data{ngrp}{sb,3}                 = ft_math(cfg,allsuj_data{ngrp}{sb,1},allsuj_data{ngrp}{sb,2});
        
    end
    
end

clearvars -except *_data ; 

nbsuj                           = 14;
[~,neighbours]                  =  h_create_design_neighbours(14,allsuj_data{1}{1},'gfp','t');

cfg                             = [];
cfg.latency                     = [0.1 0.3];
cfg.statistic                   = 'indepsamplesT';
cfg.method                      = 'montecarlo';     
cfg.correctm                    = 'cluster';        
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 0;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.neighbours                  = neighbours;
cfg.design                      = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                        = 1;
stat                            = ft_timelockstatistics(cfg, allsuj_data{2}{:,3}, allsuj_data{1}{:,3});

[min_p,p_val]                   = h_pValSort(stat) ;

stat.mask                       = stat.prob < 0.1;

stat2plot                       = allsuj_data{1}{1};
stat2plot.time                  = stat.time;
stat2plot.avg                   = stat.mask .* stat.stat;

cfg                             = [];
% cfg.xlim                        = [-0.2 1.2];
cfg.ylim                        = [-5 5];
ft_singleplotER(cfg,stat2plot);

for ngroup = 1:2
    for ncue = 1:2
        gavg_data{ngroup,ncue} = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,ncue});
    end
end

figure;

line_shape = {'-b','-r','-b','-r'};
i          = 0 ;

for ngroup = 1:2
    
    subplot(2,2,ngroup)
    hold on;
    
    for ncue = 1:2
        
        i = i + 1;
        
        plot(gavg_data{ngroup,ncue}.time,gavg_data{ngroup,ncue}.avg,line_shape{i});
        xlim([-0.1 0.6])
        ylim([0 100])
        vline(0,'-k')
        
    end
end

vline(0.19,'-k')
vline(0.23,'-k')
        

