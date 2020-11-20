% performs statisitcal analysis on timelocked data from ERF_Analysis_stat

%%
clear all; clearvars; clc;

% adding Fieldtrip path
fieldtrip_path                              = '/project/3015039.04/fieldtrip-20190618';
addpath(fieldtrip_path); ft_defaults ;

cfg                                         = [];
cfg.method                                  = 'montecarlo';                 % use the Monte Carlo Method to calculate the significance probability
cfg.statistic                               = 'ft_statfun_indepsamplesT';   % use the independent samples T-statistic as a measure to evaluate the effect at the sample level
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;                         % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.clusterstatistic                        = 'maxsum';                     % test statistic that will be evaluated under the permutation distribution.
cfg.minnbchan                               = 4;                            % minimum number of neighborhood channels that is required for a selected sample to be included  in the clustering algorithm (default=0)
cfg.tail                                    = 0;                            % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;                        % alpha level of the permutation test
cfg.numrandomization                        = 100;                          % number of draws from the permutation distribution

% design matrix
design                                      = zeros(1,size(data_stats{2,1,1}.trial,1) + size(data_stats{2,1,2}.trial,1)); % no. of trials subject performs in each condition
design(1,1:size(data_stats{2,1,1}.trial,1)) = 1;
design(1,(size(data_stats{2,1,1}.trial,1)+1):(size(data_stats{2,1,1}.trial,1) + size(data_stats{2,1,2}.trial,1))) = 2;

cfg.design                                  = design;                       % design matrix
cfg.ivar                                    = 1;                            % number or list with indices indicating the independent variable(s)

% prepare neighbours
cfg_neighb                                  = [];
cfg_neighb.method                           = 'triangulation';
cfg_neighb.layout                           = 'CTF275.lay';
neighbours                                  = ft_prepare_neighbours(cfg_neighb, downsampled_clean_icafree_data);
cfg.neighbours                              = neighbours;                   % the neighbours specify for each sensor with  which other sensors it can form clusters
cfg.latency                                 = [0 1];                        % time interval over which the experimental conditions must be compared (in seconds)

[stats]                                     = ft_timelockstatistics(cfg, data_stats{2,1,1}, data_stats{2,1,2});

[min_p , p_val]                             = h_pValSort(stats);

cfg                                         = [];
cfg.highlightsymbolseries                   = ['*','*','.','.','.'];
cfg.layout                                  = 'CTF275_helmet.mat';
cfg.contournum                              = 0;
cfg.markersymbol                            = '.';
cfg.alpha                                   = 0.05;
cfg.parameter                               ='stat';
cfg.zlim                                    = [-5 5];
ft_clusterplot(cfg,stats);

stat_to_plot                                = h_plotStat(stat_erf_ltvsrt,1e-13,0.05);

cfg                                         = [];
cfg.baseline                                = [-0.1 0];
cfg.layout                                  = 'CTF275.lay';
cfg.marker                                  = 'off';
cfg.comment                                 = 'no';
cfg.xlim                                    = [0.05 0.2];
cfg.dataname                                = {'left','right'};
cfg.ylim                                    = [-5 5];

ft_topoplotER(cfg,stat_to_plot)