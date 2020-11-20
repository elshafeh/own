function new_freq = h_transform_freq(freq,chan_index,chan_list)

for nroi = 1:length(chan_list) 
    
    cfg                 = [];
    cfg.avgoverchan     = 'yes';
    cfg.channel         = chan_index{nroi};
    
    tmp{nroi}           = ft_selectdata(cfg,freq);
    tmp{nroi}.label     = {chan_list{nroi}};
    
    tmp{nroi}.time      = freq.time;
    tmp{nroi}.freq      = freq.freq;
    
end

cfg                     = [];
cfg.parameter           = 'powspctrm';
cfg.appenddim           = 'chan';
new_freq                = ft_appendfreq(cfg,tmp{:});

if isfield(new_freq,'powspctrm')
else
    ix_pow              = [];
    for nroi = 1:length(chan_list)
        ix_pow          = cat(1,ix_pow,tmp{nroi}.powspctrm);
    end
    
    new_freq.powspctrm  = ix_pow;
    
end

if isfield(freq,'trialinfo')
    new_freq.trialinfo  = freq.trialinfo;
end