clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);


for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                %                 cfg                                 = [];
                %                 cfg.baseline                        = [-0.1 0];
                %                 data_pe                             = ft_timelockbaseline(cfg,data_pe);
                
                cfg                                 = [];
                cfg.method                          = 'amplitude';
                data_gfp                            = ft_globalmeanfield(cfg,data_pe);
                
                tmp{dis_type}                       = data_gfp;
                
                clear data_pe data_gfp
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'avg';
            cfg.operation                       = 'x1-x2';
            allsuj_data{ngrp}{sb,ncue}          = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
        end
        
        cfg                                     = [];
        cfg.parameter                           = 'avg';
        cfg.operation                           = 'x1-x2';
        allsuj_data{ngrp}{sb,3}                 = ft_math(cfg,allsuj_data{ngrp}{sb,1},allsuj_data{ngrp}{sb,2});
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub

nbsuj                           = 14;

cfg                             = [];
cfg.latency                     = [-0.1 0.4];
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
cfg.design                      = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                        = 1;
stat                            = ft_timelockstatistics(cfg, allsuj_data{2}{:,3}, allsuj_data{1}{:,3});

[min_p,p_val]                   = h_pValSort(stat) ;

stat.mask                       = stat.prob < 0.3;

stat2plot                       = allsuj_data{1}{1};
stat2plot.time                  = stat.time;
stat2plot.avg                   = stat.mask .* stat.stat;

cfg                             = [];
% cfg.xlim                        = [-0.2 1.2];
cfg.ylim                        = [-5 5];
ft_singleplotER(cfg,stat2plot);