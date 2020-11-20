clear ; clc ; 

rawDataIn                           = '../data/yc1.CnD.NewAVBroad.10t50Hz.m800p2000msCov.mat';
fprintf('loading %s\n',rawDataIn);
load(rawDataIn);

list_chan                           = 1:2;

cfg                                 = [] ; 
cfg.channel                         = list_chan; 
data_raw                            = ft_selectdata(cfg,virtsens);

cfgTF                               = [];
cfgTF.channel                       = list_chan;
cfgTF.output                        = 'fourier';
cfgTF.method                        = 'mtmconvol';
cfgTF.taper                         = 'hanning';
cfgTF.foi                           = 10:1:50;            
cfgTF.t_ftimwin                     = 3./cfgTF.foi; 
cfgTF.toi                           = -0.6:0.01:1; 

Fs                                  = 600;

cfg                                 = [] ;
cfg.channel                         = list_chan;
cfg.numcycle_ax                     = 1;        % number of cycles of the low frequyency signal to consider around the peaks/trough;
cfg.freq_TF                         = 40:50;    % frequencies of the TFR aligned on the peaks/troughs
cfg.freq                            = 11;       % THE FREQUENCY of the signal from which the peaks/troughts are extracted (low frequency in general)
cfg.axwidth                         = ceil((cfg.numcycle_ax./cfg.freq)*Fs) ; % time window around the peak/trough
cfg.meth                            = 'filter';     % how to get the phase of the signal ('TF' or 'filter')
cfg.taper                           = 'hanning';
cfg.timewin                         = [-0.6 1];
cfg.timewintr                       = cfg.freq/1000;

[sph, spow, phase_alltr, peaks_all] = ft_PAC_original(cfgTF,cfg,data_raw);