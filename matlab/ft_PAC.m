function [sph, spow, phase_alltr, peaks_all] = ft_PAC(cfgTF,cfg,data_raw)

%%% input
% cfgTF       : paramters for the time frequency analysis
% cfgTF.method (e.g. mtmconvol)
% cfgTF.output (e.g. pow)
% cfgTF.foi etc... (see fieldtrip tutorial)

% cfg         : parameters for the phase amplitude coupling
% numcycle_ax     = number of cycles of the low frequyency signal to consider around the peaks/trough;
% cfg.freq_TF     = frequencies of the TFR aligned on the peaks/troughs
% cfg.freq        = frequency of the signal from which the peaks/troughts are extracted (low frequency in general)
% cfg.axwidth     = time window around the peak/trough (ceil((numcycle_ax./cfg.freq)*Fs))
% cfg.meth        = how to get the phase of the signal ('TF' or 'filter')
% cfg.taper : not used ?
% cfg.timewin

% data_raw    : data organized according to fieldtrip configuration


%%% output
% sphs        : raw signal around low frequency peaks
% spows       : TF around alpha peaks
% phase_alltr : phase of the low frequency range signal around the detected peaks
% troughs_all : timing of the troughs
% peaks_all   : timing of the peaks


%%% Time frequency (output = fourier)
cfgTF.channel              = data_raw.label(cfg.channel(2));                 % for the TFR in the second electrode
data                       = ft_freqanalysis(cfgTF, data_raw);
data.powspctrm             = abs(data.fourierspctrm).^2;

%%% Parameters for the peaks to detect
% for TF data
%for filtered signal or raw data
ind_s                      = cfg.channel(1);                               % select only one channel



%%% get the "filtered" signal (low frequency):selection of the window of interest in the frequency of interest for each trial (from tf data or from filtered data)
if     strcmp(cfg.meth ,'TF')
    axwidth          = floor((cfg.numcycle_ax./cfg.freq)./               ...
        (cfgTF.toi(2)-cfgTF.toi(1))/2);           % half the time window around the peaktime between TF points (Fs=troughFG(1).EVENT.strms.LFP1.sampf
    
    [~, ind_tim]         = arrayfun(@(x) min(abs(x-data.time)), cfg.timewin);% index of closest value %arrayfun(@(x) min(abs(x-data_raw.time{1})), cfg.timewin);
    datawin              = ind_tim(1):ind_tim(2);
    [~, ind_tim]        = arrayfun(@(x) min(abs(x-data_raw.time{1})), cfg.timewin);% index of closest value %arrayfun(@(x) min(abs(x-data_raw.time{1})), cfg.timewin);
    datawin_raw          = ind_tim(1):ind_tim(2);
    
    
    datawin_peaks        = floor(cfg.axwidth)+1:numel(datawin)           ...
        -floor(cfg.axwidth)-1;                         % select only the part where to look at the peaks within datawin (as select half of the axwidth in each side around peak so has to not look for peaks there)
    
    cfgTF.channel        = data_raw.label(cfg.channel(1));               % get the phase in the first electrode
    cfgTF.foi            = cfg.freq;
    cfgTF.t_ftimwin      = 3./cfgTF.foi;
    data_phase           = ft_freqanalysis(cfgTF,data_raw);
    
    %     data_phase           = data; % hesham
    
    phase                = squeeze(num2cell(real(squeeze(data_phase.fourierspctrm(:,:,:,datawin))),3))';   %hesham       %phase                = phase';
    
    %phase                = num2cell(real(squeeze(data_phase.fourierspctrm(:,:,:,datawin))),2)';          %phase                = phase';
    checkpow             = squeeze(nanmean(abs(data_phase.fourierspctrm(:,:,:,datawin)).^2,4));% used for removing outliers (see below)
    clear('ind_tim')
    
elseif strcmp(cfg.meth ,'filter')
    [~, ind_tim]        = arrayfun(@(x) min(abs(x-data_raw.time{1})), cfg.timewin);% index of closest value %arrayfun(@(x) min(abs(x-data_raw.time{1})), cfg.timewin);
    datawin            = ind_tim(1):ind_tim(2);
    
    axwidth           = floor((cfg.numcycle_ax./cfg.freq)./            ...
        (data_raw.time{1}(2)-data_raw.time{1}(1))/2);    % half the time window around the peaktime between raw data points (Fs=troughFG(1).EVENT.strms.LFP1.sampf
    
    datawin_peaks      = floor(axwidth)+1:numel(datawin)-floor(axwidth)-1; % select only the part where to look at the peaks within datawin (as select half of the axwidth in each side around peak so has to not look for peaks there)
    
    
    bandwidth          = [cfg.freq-1 cfg.freq+1];
    %         % not the same datatwin as the sample times are different from TF
    order              = 3*fix(data_raw.fsample/(cfg.freq-1))+1;
    phase              = cellfun(@(x) x(datawin), cellfun(@(x) ft_preproc_bandpassfilter...
        (x(ind_s,:),data_raw.fsample, bandwidth, order, 'fir',  ...
        'twopass', 'none'),data_raw.trial, 'un', 0),'un',0); % filter the data and select the window of interest
    clear('bandwidth','order','channel')
    checkpow           = cellfun(@(x) squeeze(mean(abs(hilbert(x)))), phase, 'un', 0)'; % used for removing outliers (se below)
    checkpow           = vertcat(checkpow{:});                         % convert to string
    clear('ind_tim')
end

%%% keep only trials within 2 std from mean
% index                   = find(checkpow>mean(checkpow)-2*std(checkpow) &  checkpow<mean(checkpow)+2*std(checkpow));

% index                   = find(checkpow>mean(mean(checkpow))-2*std(std(checkpow)) &  checkpow<mean(mean(checkpow))+2*std(std(checkpow))); % hesham
index                   = 1:size(data.fourierspctrm,1);
% phase                   = phase(index);

%% get the peaks (and the raw signal & TF around)
peaks                   = cellfun(@(x) datawin_peaks(diff(x(datawin_peaks(1):datawin_peaks(end-1)))>0 & diff(x(datawin_peaks(2):datawin_peaks(end))) < 0), phase, 'un', 0); %find the peaks in each trial


if  strcmp(cfg.meth ,'TF')
    rawsig              = cellfun(@(x) x(ind_s,datawin_raw)', data_raw.trial,'un', 0);% get raw signal in the datawin
    signal              =  cfgTF.toi;
else
    rawsig              = cellfun(@(x) x(ind_s,datawin)', data_raw.trial,'un', 0);
    signal              = data_raw.time{1};
end

win                     = 1:numel(datawin);
troughs                 = cellfun(@(x) win(diff(x(1:end-1))<0 & diff(x(2:end)) > 0), phase, 'un', 0); %find the troughts in each trial

np                      = 0;
tr                      = 0;
clear('peaks_all','troughs_all','ind_tim');
for itr                     = index'
    tr                      = tr+1;
    if numel(peaks{tr})>0
        for ip              = 1:numel(peaks{tr})
            axis            = peaks{tr}(ip)-floor(axwidth):             ...
                peaks{tr}(ip)+floor(axwidth);            % get the raw data around the peaks detected for each trial
            
            %             timetr          = ceil(((1/cfg.freq)/2-cfg.timewintr)/(signal(2)-signal(1))): ...
            %                 ceil(((1/cfg.freq)/2+cfg.timewintr)/(signal(2)-signal(1))); % time window around expected trough
            
            %             timetr          = ceil(((1./cfg.freq)/2-cfg.axwidth)/(signal(2)-signal(1))): ...
            %                 ceil(((1./cfg.freq)/2+cfg.axwidth)/(signal(2)-signal(1))); % hesham: time window around expected trough
            
            
            %             if any(ismember(signal(datawin(troughs{tr})),signal(datawin(peaks{tr}(ip))-timetr))) && any(ismember(signal(datawin(troughs{tr})),signal(datawin(peaks{tr}(ip))+ timetr)))                  %((1/cfg.freq)/2-cfg.timewintr:cfgTF.toi(2)-cfgTF.toi(1):(1/cfg.freq)/2+cfg.timewintr)))
            if any(ismember(signal(datawin(troughs{tr})),signal(datawin(peaks{tr}(ip))-cfg.axwidth))) && any(ismember(signal(datawin(troughs{tr})),signal(datawin(peaks{tr}(ip))+ cfg.axwidth)))                  %((1/cfg.freq)/2-cfg.timewintr:cfgTF.toi(2)-cfgTF.toi(1):(1/cfg.freq)/2+cfg.timewintr)))
                
                np           = np+1;
                if strcmp(cfg.meth ,'TF')
                    %                 [~, rawtim_peaks]  = min(abs(signal(datawin(peaks{tr}(ip)))-data_raw.time{1}(datawin_raw)));
                    %                 %sph(np,:)    = rawsig{itr}(rawtim_peaks-cfg.axwidth_raw:...
                    %                 %                           rawtim_peaks+cfg.axwidth_raw);
                    
                    spow(np,:,:) = squeeze(data.powspctrm(itr,:,:,datawin(axis)))';% get the TF data around the peaks detected for each trial
                    %
                else
                    %                 sph(np,:)    = rawsig{itr}(axis);
                    [~, TF_peaks]  = min(abs(signal(datawin(peaks{tr}(ip)))-data.time));
                    
                    axwidth_TF     = floor((cfg.numcycle_ax./cfg.freq)./      ...
                        (cfgTF.toi(2)-cfgTF.toi(1))/2);           % half the time window around the peaktime between TF points (Fs=troughFG(1).EVENT.strms.LFP1.sampf
                    
                    spow(np,:,:) = squeeze(data.powspctrm(itr,:,:,TF_peaks-axwidth_TF:TF_peaks+axwidth_TF))';% get the TF data around the peaks detected for each trial
                end
                sph(np,:)    = phase{tr}(axis);
                %plot(phase{tr}); hold on; plot(rawsig{itr}(axis),'r')
                
                
                
                
                
                peaks_all{np}   = peaks{tr}(ip);
                phase_all{np}   = phase{tr};
                phase_alltr{np} = phase{tr}(axis);
            end
        end
    end
end


if np                       ==0
    sph                     = [];
    spow                    = [];
    Powhl                   = [];
    phase_alltr             = [];
    peaks_all               = [];
end
clear('np','tr')
Powhl                   = [];