clear ; clc ;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% suj_group{3}    = allsuj(16:end,1);
% suj_group{4}    = allsuj(16:end,2);
lst_group       = {'Old','Young'}; %,'Patients','Controls'};

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        cond_main       = 'nDT';
        fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
        fprintf('Loading %s\n',fname_in);
        load(fname_in);
        
        cfg                         = [];
        cfg.baseline                = [-0.1 0];
        allsuj_data{ngrp}{sb}       = ft_timelockbaseline(cfg,data_pe);
        
        clear data_pe
        
    end
    
    gavg_data{ngrp} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:});
    
end

clearvars -except *_data

nbsuj                   = 14;
[~,neighbours]          = h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'meg','t');

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [0 0.5];
cfg.statistic           = 'indepsamplesT'; 
cfg.method              = 'montecarlo';     % Calculation of the significance probability
cfg.correctm            = 'cluster';        % MCP correction
cfg.clusteralpha        = 0.05;             % First Threshold
cfg.clusterstatistic    = 'maxsum';
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                = 1;
stat                    = ft_timelockstatistics(cfg, allsuj_data{1}{:}, allsuj_data{2}{:});

[min_p,p_val]           = h_pValSort(stat) ;

stat.mask               = stat.prob < 0.11;
stat2plot               = allsuj_data{1}{1};
stat2plot.time          = stat.time;
stat2plot.avg           = stat.mask .* stat.stat;

figure;
cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.xlim                = [0.11 0.35];
cfg.marker              = 'off';
cfg.zlim                = [-1 1];
subplot(1,3,1)
ft_topoplotER(cfg,stat2plot);
cfg.zlim                = [-25 25];
subplot(1,3,2)
ft_topoplotER(cfg,gavg_data{1});
subplot(1,3,3)
ft_topoplotER(cfg,gavg_data{2});

chan_group{1} = {'MRC13', 'MRC14', 'MRC15', 'MRC16', 'MRC17', 'MRC22', 'MRC23', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRC42', 'MRF46', 'MRF55', 'MRF56', 'MRF63', 'MRF64', ...
    'MRF65', 'MRF66', 'MRF67', 'MRP23', 'MRP34', 'MRP35', 'MRP45', 'MRP57', ...
    'MRT11', 'MRT12', 'MRT13', 'MRT14', 'MRT22', 'MRT23', 'MRT24', 'MRT34'};

% chan_group{1}   = {'MLC14', 'MLC15', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC61', 'MLC62', 'MLC63', 'MLP23', 'MRC51', 'MRC52', 'MRC61', 'MRC62', 'MRC63', 'MZC02', 'MZC03'};
% chan_group{2}   = {'MRO11', 'MRO12', 'MRO13', 'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO31', 'MRO32', 'MRO33', 'MRO43', 'MRP31', 'MRP41', 'MRP42', 'MRP51', 'MRP52', 'MRP53', 'MRP54', 'MZO01', 'MZO02', 'MZP01'};

for chn = 1:length(chan_group)
    
    zlim        = 200;
    
    cfg         = [];
    
    cfg.xlim    = [-0.1 0.6];
    
    cfg.ylim    = [-zlim zlim];
    
    cfg.channel = chan_group{chn};
    
    subplot(1,length(chan_group),chn);
    
    %     ft_singleplotER(cfg,gavg_data{:});
    
    ft_singleplotER(cfg,allsuj_data{1}{:});
    
    %     legend({'Old','Young'});
    
    %     title('Avg Over Chan');
end


