clear ; clc ;

[~,suj,~]  = xlsread('../scripts.m/appariement_matlab_mig.xls','B:B');
suj_group{1}        = suj(:,1);
suj_group{2}        = suj(:,2);

lst_group       = {'mig','ctl'};

for ngrp = 1:length(lst_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.waveletPOW.1t150Hz.m3000p3000.AvgTrials.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        cfg                     = [];
        cfg.baseline            = [-0.6 -0.2];
        cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        cfg                     = [];
        cfg.frequency           = [5 15];
        cfg.latency             = [-0.2 2.2];
        freq                    = ft_selectdata(cfg,freq);
        
        cfg                         = [];
        cfg.time_start              = freq.time(1);
        cfg.time_end                = freq.time(end);
        cfg.time_step               = 0.05;
        cfg.time_window             = 0.05;
        freq                        = h_smoothTime(cfg,freq);
        
        allsuj_data{ngrp}{sb}   = freq; clear freq ;
        
    end
end

clearvars -except allsuj_data

[~,neighbours]     = h_create_design_neighbours(length(allsuj_data{1}),allsuj_data{1}{1},'meg','t'); clc;

cfg                     = h_create_cfg_for_cluster('unpaired',length(allsuj_data{1}),[],neighbours,1000,'cluster',4);
cfg.channel             = 'MEG';
cfg.frequency           = [5 15];
cfg.latency             = [-0.2 2];
stat                    = ft_freqstatistics(cfg, allsuj_data{2}{:}, allsuj_data{1}{:});

[min_p, p_val]          = h_pValSort(stat) ; clearvars -except stat allsuj_* min_p p_val

stat2plot               = h_plotStat(stat,0.000000001,0.05);

for cnd = 1:2
    gavg{cnd} = ft_freqgrandaverage([],allsuj_data{cnd}{:});
end

twin                    = 0.2;
tlist                   = stat.time(1):twin:stat.time(end);

% [x,y,z]                 = size(stat2plot.powspctrm);
% 
% if y == 1
%     stat2plot.avg       = squeeze(stat2plot.powspctrm);
%     stat2plot.dimord    = 'chan_time';
%     stat2plot           = rmfield(stat2plot,'powspctrm');
%     stat2plot           = rmfield(stat2plot,'freq');
% end

for t = 1:length(tlist)
    subplot(4,3,t)
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = [tlist(t) tlist(t)+twin];
    cfg.zlim    = [-2 2];
    cfg.marker  = 'off';
    ft_topoplotER(cfg,stat2plot);
end

for cnd = 1:2
    figure;
    for t = 1:length(tlist)
        subplot(4,3,t)
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.ylim    = [5 15];
        cfg.xlim    = [tlist(t) tlist(t)+twin];
        cfg.zlim    = [-0.3 0.3];
        cfg.marker  = 'off';
        ft_topoplotER(cfg,gavg{cnd});
    end
end

% figure;
% cfg         = [];
% cfg.zlim    = [-0.25 0.25];
% ft_singleplotTFR(cfg,stat2plot);
% title('Avg');

