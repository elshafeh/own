% Based on fieldtrip tutorial http://www.fieldtriptoolbox.org/faq/itc

clear ; clc ;

load ../data/pe/yc17.CnD.SomaGammaNoAVG.CoV.m800p2000ms.freq.1t120Hz.mat

cfg             = [];
cfg.trials      = 1:10;
cfg.method      = 'wavelet';
cfg.output      = 'fourier';
cfg.toi         = -1:0.02:2;
cfg.foi         = 1:2:120;
freq            = ft_freqanalysis(cfg, virtsens);

itc             = [];
itc.label       = freq.label;
itc.freq        = freq.freq;
itc.time        = freq.time;
itc.dimord      = 'chan_freq_time';

F               = freq.fourierspctrm;   % copy the Fourier spectrum
N               = size(F,1);           % number of trials

% compute inter-trial phase coherence (itpc)
itc.itpc        = F./abs(F);         % divide by amplitude
itc.itpc        = sum(itc.itpc,1);   % sum angles
itc.itpc        = abs(itc.itpc)/N;   % take the absolute value and normalize
itc.itpc        = squeeze(itc.itpc); % remove the first singleton dimension

% compute inter-trial linear coherence (itlc)
itc.itlc        = sum(F) ./ (sqrt(N*sum(abs(F).^2)));
itc.itlc        = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
itc.itlc        = squeeze(itc.itlc); % remove the first singleton dimension

figure
subplot(2, 1, 1);
imagesc(itc.time, itc.freq, squeeze(itc.itpc(1,:,:)));
axis xy
title('inter-trial phase coherence');
subplot(2, 1, 2);
imagesc(itc.time, itc.freq, squeeze(itc.itlc(1,:,:)));
axis xy
title('inter-trial linear coherence');