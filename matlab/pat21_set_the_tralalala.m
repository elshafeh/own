clear ; clc ; 

load ../data/elan/yc1.pt1.DIS.mat ;

% cnd time-win focus formul trilili

% tar p100p400 4t6Hz        	: 0.3 5  1 0.05  3
% tar p100p400 9t13Hz           : 0.3 11 2 0.03  3
% tar p100p300 30t40Hz			: 0.2 35 5 0     15
% dis p300p600  8t12Hz          : 0.3 10 2 0     5
% dis p300p600 3t7Hz            : 0.3 5  2 0.05  4
% dis p0p200 30t40Hz			: 0.2 35 5 0     15
% dis p200p400 80t90Hz			: 0.2 85 5 0     15
% dis p300p700 5t7Hz            : 0.4 6  1 0.05  1
% dis p300p700 8t14Hz			: 0.4 11 3 0.025 4
% dis p100p300 35t45Hz			: 0.2 40 5 0     15
% dis p100p200 55t75Hz 			: 0.1 60 5 0     30

st_point    = 0.3 ; tim_win     = 0.3; trilili = 0.01/2;

lm1             = st_point-trilili;lm2             = st_point+tim_win+trilili;
cfg                         = [];cfg.latency                 = [lm1 lm2];data_in                     = ft_selectdata(cfg,data_elan);

cfg               = [];cfg.method        = 'mtmfft';cfg.output        = 'powandcsd';cfg.trials        = 1;
cfg.foi           = 35;
cfg.tapsmofrq     = 10;
freq              = ft_freqanalysis(cfg,data_in);