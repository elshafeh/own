clear ; clc ; close all;

dirIN1   = '/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/rawdata/eskmi/eskmi_CAT_20170331_01.ds';
dirIN2   = '/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/rawdata/fiepa/fiepa_CAT_20170322_01.ds';

%[101 103 202 204 1 2 3 4 111 113 121 123 212 214 222 224 11 21 12 22 13 23 14 24]

cfg                     = [];
cfg.dataset             = dirIN1;
cfg.trialdef.eventtype  = 'UPPT001';
cfg.trialdef.eventvalue =  [61 62 63 64];
cfg.trialdef.prestim    =  2;
cfg.trialdef.poststim   =  1;

cfg                     = ft_definetrial(cfg);
% cfg.bpfilter            = 'yes';
% cfg.bpfreq              = [0.5 20];
cfg.channel             = {'EEG001' 'EEG002' 'EEG003' 'EEG004' 'EEG005'};
data                    = ft_preprocessing(cfg);

cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'pow'  ;
cfg.tapsmofrq   = 0.4;
cfg.foi         = 1:100;
cfg.taper       = 'dpss';
freq            =  ft_freqanalysis(cfg,data);

for n = 1:5
    subplot(1,5,n)
    plot(freq.powspctrm(n,:))
    ylim([0 8.4999e-10]);
end

% avg                     = ft_timelockanalysis([],data);
% 
% cfg = [];
% cfg.baseline = [-0.2 -0.1];
% avg = ft_timelockbaseline(cfg,avg);
% 
% for n = 1:5
%     subplot(2,5,n+5)
%     cfg         =[];
%     cfg.channel = n;
%     cfg.xlim    = [-0.1 0.6];
%     ft_singleplotER(cfg,avg);
%     hline(0,'-k');
%     vline(0,'-k');
% end