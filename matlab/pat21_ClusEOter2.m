% Run Non-parametric cluster based permutation tests against baseline

clear ; clc ; dleiftrip_addpath ; close all ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    list_dis_cond = '123';
    
    for dis_cond = 1:3
        
        fname = ['../data/tfr/' suj '.DIS' list_dis_cond(dis_cond) '.all.wav.1t100Hz.m3000p3000.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        allsuj_activation{sb,dis_cond}              = freq;
        
        clear freq
        
        fname = ['../data/tfr/' suj '.fDIS' list_dis_cond(dis_cond) '.all.wav.1t100Hz.m3000p3000.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        allsuj_baselineRep{sb,dis_cond}              = freq;
        
        clear freq
        
    end
    
end

clearvars -except allsuj_* ;

for sb = 1:size(allsuj_activation,1)
    
    fprintf('Baseline Correcting for %4s\n',['yc' num2str(sb)]);
    
    for dis_cond = 1:size(allsuj_activation,2)
        
        allsujGA{sb,dis_cond}           = allsuj_activation{sb,dis_cond};
        allsujGA{sb,dis_cond}.powspctrm = allsuj_activation{sb,dis_cond}.powspctrm  - allsuj_baselineRep{sb,dis_cond}.powspctrm;
        
    end
end

clearvars -except allsujGA ;

for sb = 1:size(allsujGA,1)
    for dis_cond = 1:size(allsujGA,2)
        cfg                     = [];
        cfg.baseline            = [-0.4 -0.2];
        cfg.baselinetype        = 'absolute';
        allsujGA{sb,dis_cond}   = ft_freqbaseline(cfg,allsujGA{sb,dis_cond});
    end
end

clearvars -except allsujGA ;

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cnd_freq = [4 7;8 15; 16 30;30 50;50 90];
cnd_stat = [1 2; 1 3; 2 3];

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.2 0.7];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

for cf = 1:5
    for cs = 1:3
        cfg.frequency           = cnd_freq(cf,:);
        stat{cf,cs}             = ft_freqstatistics(cfg, allsujGA{:,cnd_stat(cs,1)}, ...
            allsujGA{:,cnd_stat(cs,2)});
        
        stat{cf,cs}                     = rmfield(stat{cf,cs},'cfg');
        [min_p(cf,cs),p_val{cf,cs}]     = h_pValSort(stat{cf,cs});
        
    end
end

clearvars -except min_p p_val stat allsujGA

% load ../data/yctot/stat/RLNV.DIS.lb.correction.mat

p_lim = 0.05 ;

for cf = 1:size(stat,1)
    for cs = 1:size(stat,2)
        [min_p(cf,cs),p_val{cf,cs}]     = h_pValSort(stat{cf,cs});
        stat2plot{cf,cs}                = h_plotStat(stat{cf,cs},p_lim,'no');
    end
end

% list_cnd_stat = {'DIS1 v DIS2','DIS1 v DIS3','DIS2 v DIS3'};

list_cnd_stat = {'RL','RN','LN','VN'};
list_cnd_freq = {'theta','alpha','beta','lowgmma','high gamma'};

for cf = 1:5
    for cs = 1:4
        if min_p(cf,cs) < p_lim
            figure;
            cfg         =   [];
            cfg.xlim    =   -0.3:0.1:0.7;
            cfg.zlim    =   [-1 1];
            cfg.layout  = 'CTF275.lay';
            ft_topoplotTFR(cfg,stat2plot{cf,cs});
            title([list_cnd_freq{cf} ' : ' list_cnd_stat{cs}]);
        end
    end
end

cf = 1;

% for cs = 1:3
%     
%     if min_p(cf,cs) < 0.1
%         figure;
%         
%         cnd_freq = 55:5:80 ;
%         
%         for f = 1:length(cnd_freq)
%             
%             subplot(4,2,f)
%             
%             cfg         =   [];
%             cfg.ylim    =   [cnd_freq(f) cnd_freq(f)+5];
%             cfg.zlim    =   [-1 1];
%             cfg.layout  = 'CTF275.lay';
%             ft_topoplotTFR(cfg,stat2plot{cf,cs});
%             title([list_cnd_freq{cf} ' : ' list_cnd_stat{cs}])
%             
%         end
%     end
% end
% 
% cf = 1 ;
% cs = 1 ;
% 
% cfg         =   [];
% cfg.xlim    =   [0 0.4];
% cfg.ylim    =   [55 75];
% cfg.zlim    =   [-1 1];
% cfg.layout  = 'CTF275.lay';
% ft_topoplotTFR(cfg,stat2plot{cf,cs});