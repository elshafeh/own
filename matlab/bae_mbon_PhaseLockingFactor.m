function PLF_out = mbon_PhaseLockingFactor(data, cfg)

% ft_ PLF function
% 1) computes the Phase Locking Factor for each channel,
%    frequency and time of interest : PLF
% 2) Build a matrix with significant PLF only (<p, other PLF = 0): PLFsig
% 3) Build a matrix with difference between PLF computed and the Mean PLF
% 3) computes the Von Mises distribution over trials for each trial
%    at a given time point and for a given frequency : VM

%%% Input
% data          = Structure stemming from the time frequency analyses
%                 (cfg.output = 'fourier' & e.g. cfg.method = 'mtmconvol')
% index         = index of the trials of interest (e.g. only one condition),
%                 'all' if all trials are included
% indexchannel   = index of the channel of interest 'all' for all
% cfgPLF        = info for the computation of the phase locking factor
%                 (time window & frequencies of interest: cgfPLF.time/freq);
%                 cfgPLF.threshold= p value used to compute, for the
%                  number of trials contained in data, the minimum significant PLF

if strcmp(cfg.index,'all')
    cfg.index                       = 1:size(data.fourierspctrm,1);
end

if strcmp(cfg.indexchan,'all')
    cfg.indexchan                   = 1:size(data.fourierspctrm,2);
end

%%% Detect the frequency and time of interest
freqPLF                         = find(round(data.freq)==cfg.freq(1)):find(round(data.freq)==cfg.freq(2));

if isfield(data,'time')
    %     offset                      = round(data.time(1)*data.fsample);
    %     timeoi                      = unique(round(cfg.time .* data.fsample) ./ data.fsample);
    %     timePLF                     = round(timeoi .* data.fsample - offset) + 1;
    timePLF                     = find(round(data.time,3)== round(cfg.time(1),3)):find(round(data.time,3)== round(cfg.time(2),3));
else
    timePLF                     = 1;                                       % when fft
end

%%% Build up a matrix with all PLF
ang                     = data.fourierspctrm(cfg.index,cfg.indexchan, freqPLF,timePLF);
ang                     = angle(ang);                               % Computes the angles, in radians
PLF                     = squeeze(abs((sum(cos(ang) + 1i*sin(ang))))/size(data.fourierspctrm,1));% Computes the PLF

if size(PLF,3) == 1
    new(1,:,:) = PLF;
    PLF = new;
    clear new;
end

PLF_out.label           = data.label;
PLF_out.powspctrm       = PLF;
PLF_out.rayleigh        = (PLF.^2)*size(cfg.index,2);        % PLF converted to Rayleigh Z
PLF_out.p               = exp(-PLF);                         % PLF p values

%Test for signifcance of PLF

[~,threshold]           = signplf(size(cfg.index,2),cfg.alpha);
new_mask                = (PLF>threshold);

PLF(PLF<threshold)      = 0;

PLF_out.sig             = PLF;
PLF_out.mask            = new_mask;

PLF_out.dimord          = 'chan_freq_time';
PLF_out.time            = data.time(timePLF);
PLF_out.freq            = data.freq(freqPLF);