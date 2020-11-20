clear ;

stim_list                   =  dir('../../data/stim/dis/*wav');

snd_split                   = [];

for n = 1:length(stim_list)
    
    max_freq                = [];
    
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
    
    freq_width              = 3;
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
        
        max_freq(nf)        = data;
        
    end
    
    flg                     = max(max_freq);
    ix                      = freq_list(find(max_freq==flg));
    
    %     if ix < 1600
    %         snd_split(n,1)      = 1;
    %     else
    %         snd_split(n,1)      = 2;
    %     end
    
    snd_split(n,1)          = ix;
    snd_split(n,2)          = flg;
    
end

keep max_freq snd_split stim_list

snd_split                       = sortrows(snd_split,1);

snd_split(:,3)                  = 2;
snd_split(1:18,3)               = 1;
snd_split(23:40,3)              = 3;

low_snd                         = snd_split(snd_split(:,3) == 1,:);
hgh_snd                         = snd_split(snd_split(:,3) == 3,:);
mid_snd                         = snd_split(snd_split(:,3) == 2,:);

final_list                      = [];

for n = 1:size(snd_split,1)
    
    %     final_list(n).sound_name    = stim_list(n).name(1:end-4);
    %     final_list(n).frequency     = snd_split(n,1);
    %     final_list(n).label         = tmp_list{snd_split(n,3)}; 
    
    tmp_list                    = {'low','mid','high'};
    final_list{n,1}             = stim_list(n).name(1:end-4);
    final_list{n,2}             = tmp_list{snd_split(n,3)};

end

keep final_list

save final_dis_frequency_list.mat

% writetable(struct2table(final_list),'../../documents/dis_frequency_list.xlsx');