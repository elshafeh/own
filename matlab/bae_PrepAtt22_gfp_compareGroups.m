clear ; clc ;

load ../data_fieldtrip/index/age_group_performance_split.mat

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        cond_main       = 'nDT';
        
        if strcmp(cond_main,'CnD');
            fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
        else
            fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
        end
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in);
        
        cfg                         = [];
        cfg.baseline                = [-0.1 0];
        data_pe                     = ft_timelockbaseline(cfg,data_pe);
        
        cfg                         = [];
        cfg.method                  = 'amplitude';
        data_gfp1                   = ft_globalmeanfield(cfg,data_pe);
        
        
        %         cfg.time_start               = 0;
        %         cfg.time_end                 = 1.2;
        %         cfg.time_step                = 0.05;
        %         cfg.time_window              = 0.05;
        %         data_gfp1                    = h_smoothTime(cfg,data_gfp1);
        
        allsuj_data{ngroup}{sb}     = data_gfp1;
        
        clear data_pe data_gfp*
        
    end
    
    gavg_data{ngroup} = ft_timelockgrandaverage([],allsuj_data{ngroup}{:});
    
end

clearvars -except *_data ; clc ; 

list_compare            = [1 2; 3 4;1 3; 2 4];

for ntest = 1:length(list_compare)
    
    nbsuj                   = length(allsuj_data{list_compare(ntest,1)});
    
    [design,neighbours]     = h_create_design_neighbours(nbsuj,allsuj_data{list_compare(ntest,1)}{1},'gfp','t');
    
    cfg                     = [];
    cfg.latency             = [0 0.5];
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
    
    stat{ntest}             = ft_timelockstatistics(cfg, allsuj_data{list_compare(ntest,1)}{:},allsuj_data{list_compare(ntest,2)}{:});
    
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]           = h_pValSort(stat{ntest}) ;
end

cfg             = [];
cfg.p_threshold = 0.05;
cfg.lineWidth   = 3;
cfg.time_limit  = [-0.1 1.2];
cfg.z_limit     = [0 70];
cfg.legend      = {'Young Fast','Young Slow'};
cfg.fontSize    = 18;
h_plotSingleERFstat(cfg,stat{2},gavg_data{3},gavg_data{4});


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


