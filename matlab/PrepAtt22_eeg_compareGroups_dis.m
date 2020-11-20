clear ; clc ;

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

suj_group{1}    = allsuj(2:end,1);
suj_group{2}    = allsuj(2:end,2);

suj_list        = [suj_group{1};suj_group{2}];

lst_group       = {'Old','Young'};

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        i               = 0 ;
        
        for cond_main       = {'1DIS.eeg','1fDIS.eeg'}
            
            fname_in        = ['../data/' suj '/field/' suj '.' cond_main{:} '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg             = [];
            cfg.baseline    = [-0.1 0];
            data_pe         = ft_timelockbaseline(cfg,data_pe);
            
            i               = i + 1;
            tmp{i}          = data_pe;
            
            clear data_pe
            
        end
        
        cfg                                     = [];
        cfg.parameter                           = 'avg';
        cfg.operation                           = 'x1-x2';
        data_pe                                 = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
        
        for nchan = 1:5
            
            cfg                                 = [];
            cfg.channel                         = nchan;
            allsuj_data{ngrp}{sb,nchan}         = ft_selectdata(cfg,data_pe);
            
        end
        
        clear data_pe 
        
    end
    
    for nchan = 1:size(allsuj_data{ngrp},2)
        
        gavg_data{ngrp,nchan} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,nchan});
        
    end
    
end

clearvars -except *_data ; clc ; 

nbsuj                   = size(allsuj_data{1},1);

cfg                     = [];
cfg.latency             = [-0.1 0.7];
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
cfg.design              = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                = 1;

for nchan = 1:size(allsuj_data{1},2)
    stat{nchan}                     = ft_timelockstatistics(cfg, allsuj_data{1}{:,nchan}, allsuj_data{2}{:,nchan});
    [min_p(nchan),p_val{nchan}]     = h_pValSort(stat{nchan}) ;
end

clearvars -except *_data min_p p_val stat; clc ; 

for ngrp = 1:2
    for nchan = 1:5
        
        gavg_data{ngrp,nchan}.avg = -gavg_data{ngrp,nchan}.avg;
        
    end
end

cfg             = [];
cfg.p_threshold = 0.1;
cfg.lineWidth   = 3;
cfg.time_limit  = [-0.1 0.7];
cfg.z_limit     = [-10 10];
cfg.fontSize    = 18;

for nchan = 1:length(stat)
    subplot(2,3,nchan)
    h_plotSingleERFstat(cfg,stat{nchan},gavg_data{1,nchan},gavg_data{2,nchan});
    hline(0,'--k')
    vline(0,'--k')
    title([stat{nchan}.label]);% ' ' min_p(nchan)])
    legend({'old','young'});
end


% for nchan = 1:length(stat)
%
%     figure;
%
%     for ngrp = 1:2
%
%         subplot(2,1,ngrp)
%
%         cfg                     = [];
%         cfg.xlim                = [-0.1 0.6];
%         cfg.ylim                = [-10 10];
%         ft_singleplotER(cfg,allsuj_data{ngrp}{:,nchan});
%
%     end
% end
%
% % stat.mask               = stat.prob < 0.11;
%
% stat2plot               = allsuj_data{1}{1};
% stat2plot.time          = stat.time;
% stat2plot.avg           = stat.mask .* stat.stat;
%
%
% % cfg                     = [];
% % cfg.xlim                = [-0.2 1.2];
% % subplot(1,2,1);
% % cfg.ylim                = [-3 3];
% % ft_singleplotER(cfg,stat2plot);
% % cfg.ylim                = [0 60];
% % subplot(1,2,2);
% % hold on
% % ft_singleplotER(cfg,gavg_data{:});
% % legend({'Old CnD','Young CnD'});
% % vline(0.6,'--k')
% % vline(1,'--k')
%
% subplot(2,2,1:2)
% cfg                     = [];
% cfg.xlim                = [-0.2 1.2];
% cfg.ylim                = [0 60];
% ft_singleplotER(cfg,gavg_data{:});
% legend({'Old CnD','Young CnD'});
% vline(0.6,'--k')
% vline(1,'--k')
% title('Global Field Power');
% cfg                     = [];
% cfg.xlim                = [0.6 1];
% cfg.zlim                = [-30 30];
% cfg.layout              = 'CTF275.lay';
% cfg.comment             = 'no';
% % cfg.label               = 'no';
% cfg.marker              = 'off';
% cfg.colorbar            = 'yes';
% subplot(2,2,3)
% ft_topoplotER(cfg,pe_avg_data{1});
%
% title('Old CnD Avg 600-1000ms')
% subplot(2,2,4)
% ft_topoplotER(cfg,pe_avg_data{2});
% title('Young CnD Avg 600-1000ms')


