% Run Non-parametric cluster based permutation tests against baseline

clear ; clc ; dleiftrip_addpath ; close all ;

for a = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(a))];
    
    lst_dis     =   {'DIS1','fDIS1'};
    ext1        =   '.all.wav.5t15Hz.m4000p4000.MinusEvoked.mat' ;
    
    for cnd_dis = 1:2
        fname_in    = ['../data/tfr/' suj '.' lst_dis{cnd_dis} ext1];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        tf_dis{cnd_dis} = freq ; clear freq;
    end
    
    allsuj_activation{a,1}                        = tf_dis{1};
    allsuj_baselineRep{a,1}                       = tf_dis{2}; clear tf_dis ;
    
end

clearvars -except *allsuj_* ;

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.minnbchan           = 3;
cfg.frequency           = [5 15];
cfg.latency             = [0 1];
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
[min_p, p_val]          = h_pValSort(stat) ;

clustno                 = 2;
stat2plot               = h_plotStat(stat,p_val(1,clustno)-0.00001,p_val(1,clustno)+0.00001);

cfg                     = [];
cfg.zlim                = [-1 1];
cfg.comment             = 'no';
cfg.marker              = 'off';
cfg.layout              = 'CTF275.lay';
ft_topoplotTFR(cfg,stat2plot);

% list_left = {'MLC15', 'MLC16', 'MLC17', 'MLC24', 'MLC25', 'MLF56', 'MLF65', 'MLF66', ...
%     'MLF67', 'MLO14', 'MLP35', 'MLP43', 'MLP44', 'MLP45', 'MLP54', 'MLP55', 'MLP56', 'MLP57',...
%     'MLT12', 'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT26', ...
%     'MLT33', 'MLT34', 'MLT35', 'MLT36', 'MLT44', 'MLT45'};
% 
% list_right = {'MRC15', 'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRF56', 'MRF65', 'MRF66', 'MRF67', ...
%     'MRO14', 'MRP35', 'MRP44', 'MRP45', 'MRP55', 'MRP56', 'MRP57', 'MRT12', 'MRT13', ...
%     'MRT14', 'MRT15', 'MRT16', 'MRT23', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT35', 'MRT36'};
% 
% cfg             = [];
% cfg.zlim        = [-1 1];
% cfg.channel     = list_right;
% ft_singleplotTFR(cfg,stat2plot);
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold');
% title('');