clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% patient_list;
% suj_group{1} = fp_list_meg;
% suj_group{2} = cn_list_meg; clearvars -except suj_group

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}        = allsuj(2:15,1);
suj_group{2}        = allsuj(2:15,2);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        
        cond_main                   = 'DIS1';
        
        dir_data                    = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';

        if strcmp(cond_main,'CnD')
            fname_in                = [dir_data  suj '.' cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
        else
            fname_in                = [dir_data  suj '.' cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
        end
        
        cfg                         = [];
        cfg.baseline                = [-0.1 0];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in);
        
        data_pe                     = ft_timelockbaseline(cfg,data_pe);
        
        cfg                         = [];
        cfg.method                  = 'amplitude';
        data_gfp                    = ft_globalmeanfield(cfg,data_pe);
        
        allsuj_data{ngrp}{sb}       = data_gfp;
        
        clear data_pe data_gfp*
        
    end
    
    gavg_data{ngrp} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:});
    
end

clearvars -except *_data ; clc ; 

nbsuj                   = length(allsuj_data{1});

cfg                     = [];
cfg.latency             = [-0.1 0.65];
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
stat                    = ft_timelockstatistics(cfg, allsuj_data{1}{:}, allsuj_data{2}{:});

[min_p,p_val]           = h_pValSort(stat) ;

cfg             = [];
cfg.p_threshold = 0.1;
cfg.lineWidth   = 3;
cfg.time_limit  = [-0.1 0.7];
cfg.z_limit     = [0 100];
cfg.fontSize    = 18;
h_plotSingleERFstat(cfg,stat,gavg_data{1},gavg_data{2});
legend({'Aged','Young'});
set(gca,'fontsize', 18)

% stat.mask               = stat.prob < 0.11;
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


