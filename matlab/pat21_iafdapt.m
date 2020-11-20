function [freq, iaf] = iafdapt(freq,nw_chn,nw_lst,tlim,flim)

if isfield(freq,'hidden_trialinfo')
    freq    = rmfield(freq,'hidden_trialinfo');
end

for l = 1:size(nw_chn,1)
    cfg             = [];
    cfg.channel     = nw_chn(l,:);
    cfg.avgoverchan = 'yes';
    nwfrq{l}        = ft_selectdata(cfg,freq);
    nwfrq{l}.label  = nw_lst(l);
end

cfg                 = [];
cfg.parameter       = 'powspctrm';cfg.appenddim   = 'chan';
freq                = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq

cfg                 = [];
cfg.frequency       = flim;
cfg.latency         = tlim;
cfg.avgovertime     = 'yes';
tmp                 = ft_selectdata(cfg,freq);

for chn = 1:length(tmp.label)
    
    data    = squeeze(tmp.powspctrm(chn,:));
    
    if length(tmp.label) > 2
        if chn < 3;val = find(data == max(data));else val = find(data == min(data));end
    else
        val = find(data == min(data));
    end
    
    iaf(chn)  = round(tmp.freq(val));
    
end

clear tmp;