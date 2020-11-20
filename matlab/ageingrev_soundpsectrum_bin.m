clear ;

stim_list                   =  dir('../../data/stim/dis/*wav');
max_freq                    = [];

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
    
    freq.powspctrm          = freq.powspctrm ./ max(freq.powspctrm);
    
    freq_width              = 1000;
    freq_list               = 0:freq_width:22000;
    
    for nf = 1:length(freq_list)
        
        chk                 = abs(freq.freq - freq_list(nf));
        im1                 = find(chk == min(chk));
        
        chk                 = abs(freq.freq - (freq_list(nf)+freq_width));
        im2                 = find(chk == min(chk));
        
        if ~isempty(im1) && ~isempty(im2)
            data            = mean(freq.powspctrm(im1:im2));
        else
            data            = 0;
        end
        
        max_freq(n,nf)      = data;
        
    end
    
    subplot(5,8,n)
    bar(freq_list,max_freq(n,:));
    
    vline(1500,'--k');
    vline(3000,'--k');
    vline(4000,'--k');
    
    %     vline(10000,'--k');
    
    xlim([0 5000]);
    
    
end

keep max_freq
