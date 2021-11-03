clear;

% dsFileName              	= '/project/3035002.01/raw/sub-002/ses-meg01/meg/sub002ses01_3035002.01_20210907_01.ds';
% dsFileName              	= '/project/3035002.01/raw/sub-003/ses-meg01/meg/sub003ses01_3035002.01_20210908_01.ds';
% dsFileName              	= '/project/3035002.01/raw/sub-004/ses-meg01/meg/sub004ses01_3035002.01_20210915_01.ds';
% dsFileName              	= '/project/3035002.01/raw/sub-005/ses-meg02/meg/sub005ses02_3035002.01_20210922_01.ds';
% dsFileName              	= '/project/3035002.01/raw/sub-006/ses-meg01/meg/sub006ses01_3035002.01_20210928_01.ds';
dsFileName              	= '/project/3035002.01/raw/sub-007/ses-meg01/meg/sub007ses01_3035002.01_20211020_01.ds';

cfg                         = [];
cfg.dataset                 = dsFileName;
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'UPPT001';  %'frontpanel trigger'
cfg.trialdef.eventvalue     = [111   112   121   122];
cfg.trialdef.prestim        = 1; % in seconds
cfg.trialdef.poststim       = 3; % in seconds
cfg                         = ft_definetrial(cfg);

cfg.continuous              = 'yes';
cfg.channel                 = {'MEG'};
data                        = ft_preprocessing(cfg);

cfg                         = [];
cfg.method                  = 'mtmfft';
cfg.output                  = 'pow';
cfg.taper                   = 'boxcar';
cfg.foilim                  = [1 100];
data_psd_high               = ft_freqanalysis(cfg, data);

%%

%plot
figure;
plot(data_psd_high.freq, mean(data_psd_high.powspctrm, 1))
xlabel('Frequency (Hz)');
ylabel('Power)');
title('All trials');
xlim([1 30])