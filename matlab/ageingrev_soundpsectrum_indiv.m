clear ;

stim_list                   =  dir('../../data/stim/dis/*wav');
check                       = [];

for n = 1:length(stim_list)
    
    fname                   = [stim_list(n).folder filesep stim_list(n).name];
    [soundfile,fs]          = audioread(fname);
    
    signal                  = soundfile(:,1);
    
    avg                     = [];
    avg.time                = [1:length(signal)] * 1/fs;
    avg.label               = {'wav'};
    avg.dimord              = 'chan_time';
    avg.avg                 = signal';
    
    cfg                     = [];
    cfg.method              = 'mtmfft';
    cfg.taper               = 'dpss';
    cfg.tapsmofrq           = 1/0.3;
    freq                    = ft_freqanalysis(cfg,avg);
    
    freq.powspctrm          = freq.powspctrm ./ mean(freq.powspctrm);
    
    cfg                     = [];
    cfg.xlim                = [freq.freq(1) freq.freq(end)];
    cfg.ylim                = [0 1000];
    cfg.linewidth           = 1;
    
    subplot(5,8,n)
    ft_singleplotER(cfg,freq);
    
    title(['Sound' num2str(n)]);    %upper(stim_list(n).name));
    
    yticks(cfg.ylim);
    %     xlabel('Frequency (Hz)')
    %     ylabel('Normalized Power')
    set(gca,'FontSize',14,'FontName', 'Calibri');
    
end