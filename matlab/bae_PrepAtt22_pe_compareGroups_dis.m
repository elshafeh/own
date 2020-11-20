clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

patient_list ;
suj_group{1}    = fp_list_meg;
suj_group{2}    = cn_list_meg;

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'1DIS','1fDIS'};
        
        for dis_type = 1:2
            
            fname_in                            = ['../data/' suj '/field/' suj '.' cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            tmp{dis_type}                       = data_pe;
            
            clear data_pe data_gfp
            
        end
        
        allsuj_data{ngrp}{sb}               = tmp{1};
        allsuj_data{ngrp}{sb}.avg           = tmp{1}.avg - tmp{2}.avg ;
        
        cfg                                 = [];
        cfg.baseline                        = [-0.1 0];
        allsuj_data{ngrp}{sb}               = ft_timelockbaseline(cfg,allsuj_data{ngrp}{sb});
        
    end
        
end

clearvars -except *_data cond_sub

nbsuj                   = length(allsuj_data{1});
[~,neighbours]          = h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'meg','t');

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.1 0.7];
cfg.statistic           = 'indepsamplesT'; 
cfg.method              = 'montecarlo';     % Calculation of the significance probability
cfg.correctm            = 'cluster';        % MCP correction
cfg.clusteralpha        = 0.05;             % First Threshold
cfg.clusterstatistic    = 'maxsum';
cfg.minnbchan           = 4;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                = 1;
stat                    = ft_timelockstatistics(cfg, allsuj_data{1}{:}, allsuj_data{2}{:});

[min_p,p_val]           = h_pValSort(stat) ;

stat.mask               = stat.prob < 0.05;
stat2plot               = allsuj_data{1}{1};
stat2plot.time          = stat.time;
stat2plot.avg           = stat.mask .* stat.stat;

figure;
cfg                     = [];
cfg.layout              = 'CTF275.lay';
% cfg.xlim                = [0.25 0.37];
cfg.marker              = 'off';
cfg.comment             = 'no';
cfg.zlim                = [-3 3];
ft_topoplotER(cfg,stat2plot);

figure;
cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.xlim                = [0.25 0.44];
cfg.marker              = 'off';
cfg.comment             = 'no';
cfg.zlim                = [-5 5];
subplot(2,3,1)
ft_topoplotER(cfg,stat2plot); title('Stat Patient v Control 250-440 ms')
cfg.zlim                = [-40 40];
subplot(2,3,2)
ft_topoplotER(cfg,ft_timelockgrandaverage([],allsuj_data{1}{:})); title('Patient');
subplot(2,3,3)
ft_topoplotER(cfg,ft_timelockgrandaverage([],allsuj_data{2}{:})); title('Control');
cfg         = [];
cfg.channel = {'MRC17', 'MRC25', 'MRC32', 'MRF67', 'MRO14', 'MRP23', 'MRP34', 'MRP35', 'MRP43', ... 
    'MRP44', 'MRP45', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT26'};
cfg.xlim    = [-0.1 0.4];
cfg.ylim    = [-200 50];
subplot(2,3,4:6)
ft_singleplotER(cfg,ft_timelockgrandaverage([],allsuj_data{1}{:}),ft_timelockgrandaverage([],allsuj_data{2}{:}));
title(''); legend('Patient','Control');