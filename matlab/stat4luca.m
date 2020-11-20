clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

data{1,1}                       = [];
data{1,1}.avg                   = rand(5,81);
data{1,1}.time                  = 1:81;
data{1,1}.label                 = {'ch1' 'ch2' 'ch3' 'ch4' 'ch5'};
data{1,1}.dimord                = 'chan_time';


data{1,2}                       = [];
data{1,2}.avg                   = rand(5,81);
data{1,2}.time                  = 1:81;
data{1,2}.label                 = {'ch1' 'ch2' 'ch3' 'ch4' 'ch5'};
data{1,2}.dimord                = 'chan_time';

data{2,1}                       = [];
data{2,1}.avg                   = rand(5,81);
data{2,1}.time                  = 1:81;
data{2,1}.label                 = {'ch1' 'ch2' 'ch3' 'ch4' 'ch5'};
data{2,1}.dimord                = 'chan_time';


data{2,2}                       = [];
data{2,2}.avg                   = rand(5,81);
data{2,2}.time                  = 1:81;
data{2,2}.label                 = {'ch1' 'ch2' 'ch3' 'ch4' 'ch5'};
data{2,2}.dimord                = 'chan_time';


data{3,1}                       = [];
data{3,1}.avg                   = rand(5,81);
data{3,1}.time                  = 1:81;
data{3,1}.label                 = {'ch1' 'ch2' 'ch3' 'ch4' 'ch5'};
data{3,1}.dimord                = 'chan_time';


data{3,2}                       = [];
data{3,2}.avg                   = rand(5,81);
data{3,2}.time                  = 1:81;
data{3,2}.label                 = {'ch1' 'ch2' 'ch3' 'ch4' 'ch5'};
data{3,2}.dimord                = 'chan_time';

nb_suj                          = size(data,1);
[design,neighbours]             = h_create_design_neighbours(nb_suj,data{1,1},'gfp','t');

cfg                         	= [];
cfg.latency                     = [1 10];
cfg.statistic                   = 'ft_statfun_depsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 0;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.uvar                        = 1;
cfg.ivar                        = 2;
cfg.neighbours                  = neighbours;
cfg.design                      = design;

stat                            = ft_timelockstatistics(cfg, data{:,1}, data{:,2});