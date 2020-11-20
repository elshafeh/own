% Run Non-parametric cluster based permutation tests against baseline

% load ../data/yctot/stat/RLNV.DIS.lb.correction.mat
% load ../data/yctot/stat/RLNV.DIS.no.lb.correction.mat
% load ../data/yctot/stat/dis123.no.lb.correction.mat
% load ../data/yctot/stat/dis123.lb.correction.mat
% load('../data/yctot/stat/RLN.nDT.Sensor.mat','stat');

clear ; clc ; dleiftrip_addpath ; close all ;

for sb = 1:14
    
    suj_list        = [1:4 8:17];
    suj             = ['yc' num2str(suj_list(sb))];
    list_dis_cond   = 'VN';
    
    for dis_cond = 1:length(list_dis_cond)
        
        fname = ['../data/tfr/' suj '.' list_dis_cond(dis_cond) 'DIS.all.wav.40t150Hz.m1000p1000.MinusEvoked.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        freq1   = freq;  clear freq;
        
        fname = ['../data/tfr/' suj '.' list_dis_cond(dis_cond) 'fDIS.all.wav.40t150Hz.m1000p1000.MinusEvoked.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        freq2   = freq;  clear freq;
        
        allsujGA{sb,dis_cond}           = freq1;
        allsujGA{sb,dis_cond}.powspctrm = freq1.powspctrm  - freq2.powspctrm;
        
        
    end
    
end


clearvars -except allsujGA ;

for sb = 1:size(allsujGA,1)
    for dis_cond = 1:size(allsujGA,2)
        cfg                     = [];
        cfg.baseline            = [-0.2 -0.1];
        cfg.baselinetype        = 'absolute';
        allsujGA{sb,dis_cond}   = ft_freqbaseline(cfg,allsujGA{sb,dis_cond});
    end
end

clearvars -except allsujGA ;

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cnd_stat = [1 2];

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.2 0.7];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 2;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;
cfg.frequency           = [50 120];

for cs = 1
    stat{cs}                        = ft_freqstatistics(cfg, allsujGA{:,cnd_stat(cs,1)},allsujGA{:,cnd_stat(cs,2)});
    stat{cs}                        = rmfield(stat{cs},'cfg');
    [min_p(cs),p_val{cs}]           = h_pValSort(stat{cs});
end

for cs = 1:length(stat)
    stat2plot{cs}               = h_plotStat(stat{cs},0.00001,0.8);
end

for cs = 1:length(stat)
    figure;
    cfg         =   [];
    cfg.xlim    =   -0.2:0.1:0.6;
    cfg.zlim    =   [-1 1];
    cfg.layout  = 'CTF275.lay';
    ft_topoplotTFR(cfg,stat2plot{cs});
end

% list_cnd_stat = {'RL','RN','LN'};
% list_cnd_stat = {'DIS1 v DIS2','DIS1 v DIS3','DIS2 v DIS3'};
% list_cnd_stat = {'RL','RN','LN','VN'};
% list_cnd_freq = {'theta','alpha','beta','lowgmma','high gamma'};
% for cs = 1:3
%     if min_p(cs) < 0.1
%         figure;
%         cnd_freq = list_freq(1):list_win(cf):list_freq(2) ;
%         for f = 1:length(cnd_freq)
%             subplot(list_sub(1),list_sub(2),f)
%             cfg         =   [];
%             if cf < 3
%                 cfg.ylim    =   [cnd_freq(f) cnd_freq(f)];
%             else
%                 cfg.ylim    =   [cnd_freq(f) cnd_freq(f)+list_win(cf)];
%             end
%             cfg.zlim    =   [-0.5 0.5];
%             cfg.layout  = 'CTF275.lay';
%             ft_topoplotTFR(cfg,stat2plot{cs});
%             title([list_cnd_freq{cf} ' : ' list_cnd_stat{cs}])
%         end
%     end
% end