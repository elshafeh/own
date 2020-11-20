function fSlct = h_tf2ep(freq,frequency,latency,chan)

cfg = [];

if ~isempty(frequency)
    cfg.frequency           = frequency;
    cfg.avgoverfreq         = 'yes';
end

if ~isempty(latency)
    cfg.latency         = latency;
    cfg.avgovertime     = 'yes';
end

if ~isempty(chan)
    cfg.channel             = chan;
    cfg.avgoverchan         = 'yes';
end

fSlct = ft_selectdata(cfg,freq);