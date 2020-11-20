clear ;

stim_list               =  dir('../../data/stim/dis/*wav');
check                   = [];

for n = 1:length(stim_list)
    
    fname               = [stim_list(n).folder filesep stim_list(n).name];
    [soundfile,fs]      = audioread(fname);
    
    signal              = soundfile(:,1);
    
    %     plot(psd(spectrum.periodogram,signal,'Fs',fs,'NFFT',length(signal)));
    
    avg                 = [];
    avg.time            = [1:length(signal)] * 1/fs;
    avg.label           = {'wav'};
    avg.dimord          = 'chan_time';
    avg.avg             = signal';
    
    alldata{1}{n}       = avg; clear avg;
    
end

keep alldata

stim_list               =  dir('../../data/stim/tar/*wav');
check                   = [];

for n = 1:length(stim_list)
    
    fname               = [stim_list(n).folder filesep stim_list(n).name];
    [soundfile,fs]      = audioread(fname);
    
    signal              = soundfile(:,1);
    
    %     plot(psd(spectrum.periodogram,signal,'Fs',fs,'NFFT',length(signal)));
    
    avg                 = [];
    avg.time            = [1:length(signal)] * 1/fs;
    avg.label           = {'wav'};
    avg.dimord          = 'chan_time';
    avg.avg             = signal';
    
    alldata{2}{n}       = avg; clear avg;
    
end


keep alldata freq

for ns = 1:2
    
    cfg                     = [];
    cfg.method              = 'mtmfft';
    cfg.taper               = 'dpss';
    cfg.tapsmofrq           = 1/0.1;
    freq{ns}                = ft_freqanalysis(cfg,ft_timelockgrandaverage([],alldata{ns}{:}));
    
    freq{ns}.powspctrm      = freq{ns}.powspctrm ./ mean(freq{ns}.powspctrm);
    
    
    list_stim               = {'Distracting Sound','Target'};
    
    cfg                     = [];
    cfg.xlim                = [freq{1}.freq(1) freq{1}.freq(end)];
    cfg.ylim                = [0 max(freq{ns}.powspctrm)];
        
    subplot(2,1,ns)
    ft_singleplotER(cfg,freq{ns});
    set(gca,'FontSize',20,'FontName', 'Calibri');
    title(list_stim{ns});
    xlabel('Frequency (Hz)')
    ylabel('Normalized Power')
    
end