clear ; clc ;

cfg             = [];
cfg.method      = 'amplow_amphigh';cfg.fsample     = 1000;
cfg.trllen      = 10;cfg.numtrl      = 10;
cfg.output      = 'all';cfg.s1.freq     = 6;
cfg.s1.phase    = 0;cfg.s1.ampl     = 1;
cfg.s2.freq     = 20;cfg.s2.phase    = 0;cfg.s2.ampl     = 1;cfg.s3.freq     = 0;cfg.s3.phase    = 0;
cfg.s3.ampl     = 1;cfg.s4.freq     = 1;cfg.s4.phase    = -1*pi;cfg.s4.ampl     = 1;
data            = ft_freqsimulation(cfg);

% cfg             = [];
% cfg.method      = 'mtmfft';
% cfg.channel     = 'mix';
% cfg.output      = 'pow';
% cfg.taper       = 'hanning';
% cfg.foilim      = [2 60];
% fft_data        = ft_freqanalysis(cfg,data);
% cfg             = [];
% cfg.method      = 'mtmconvol';
% cfg.channel     = 'mix';
% cfg.output      = 'pow';
% cfg.taper       = 'hanning';
% cfg.foi         = 2:2:60;
% cfg.toi         = data.time{1}(3001:7000);
% cfg.t_ftimwin   = 4./cfg.foi;
% cfg.keeptrials  = 'yes';
% freq1           = ft_freqanalysis(cfg,data);

% cfg             = [];
% cfg.covariance  = 'yes';
% cfg.keeptrials  = 'no';
% cfg.removemean  = 'yes';
% timelock        = ft_timelockanalysis(cfg,freq1);
% freqlabel       = 2:2:60;
% cov             = timelock.cov;
% d               = sqrt(diag(cov));
% r               = cov ./ (d*d');
%
% figure;
% imagesc(freqlabel,freqlabel,r)
% title('correlation')
% colorbar
% axis xy

cfg                     = [];
cfg.hilbert             = 'abs';
cfg.channel             = 'mix';
cfg.bpfilter            = 'yes';
cfg.bpfreq              = [4 8]; %do not bandpass to tight, then amplitude modulation is lost
data_bp6                = ft_preprocessing(cfg, data);
data_bp6.label          = {'mix@6Hz'};

cfg.bpfreq              = [18 22];
data_bp20               = ft_preprocessing(cfg, data);
data_bp20.label         = {'mix@20Hz'};

data_bp                 = ft_appenddata([], data_bp6, data_bp20);

cfg                     = [];
% cfg.method              = 'mtmfft';
% cfg.output              = 'powandcsd';
cfg.method              = 'wavelet';
cfg.output              = 'powandcsd';
cfg.taper               = 'hanning';
cfg.foilim              = [0 60];
cfg.keeptrials          = 'no';
cfg.channelcmb          = {'all', 'all'};
freq3                   = ft_freqanalysis(cfg, data_bp);
% freq3_coh               = ft_freqdescriptives([], freq3);