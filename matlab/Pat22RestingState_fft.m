clear ;

addpath('/Users/heshamelshafei/Documents/GitHub/fieldtrip/');
ft_defaults;

preprocFileName             = '../../data/resting/magni_restingState.mat';
load(preprocFileName);

cfg                         = [];
cfg.output                  = 'pow';
cfg.method                  = 'mtmfft';
cfg.taper                   = 'hanning';
cfg.foi                     = 1:40;
freq                        = ft_freqanalysis(cfg, dataPostICA);

freqBsl                     = freq;
freqBsl.powspctrm           = (freqBsl.powspctrm - mean(freqBsl.powspctrm,2)) ./ mean(freqBsl.powspctrm,2);

cfg                         = [];
cfg.layout                  = 'CTF275.lay';
ft_singleplotER(cfg,freqBsl)

% cfg                         = [];
% cfg.method                  = 'wavelet';
% cfg.output                  = 'pow';
% cfg.keeptrials              = 'no';
% cfg.width                   = 7 ;
% cfg.gwidth                  = 4 ;
% cfg.toi                     = dataPostICA.time{1}(1):0.1:dataPostICA.time{1}(end);
% cfg.foi                     = 1:120;
% freq                        = ft_freqanalysis(cfg,dataPostICA);
% 
% cfg                         = [];
% cfg.baseline                = [freq.time(1) freq.time(end)];
% cfg.baselinetype            = 'normchange';
% freqBsl                     = ft_freqbaseline(cfg,freq);
% 
% time_vect                   = linspace(freq.time(1),freq.time(end),10);
% time_diff                   = time_vect(2)-time_vect(1);
% 
% for ntime = 1:length(time_vect)-1
%     
%     subplot(2,5,ntime)
%     cfg                         = [];
%     cfg.layout                  = 'CTF275.lay';
%     cfg.xlim                    = [time_vect(ntime) time_vect(ntime)+time_diff];
%     cfg.ylim                    = [7 15];
%     %     cfg.zlim                    = [-0.5 0.5];
%     cfg.marker                  = 'off';
%     ft_topoplotER(cfg,freqBsl);
%     
% end