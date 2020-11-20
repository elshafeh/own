function freq_adjust = ageingrev_infunc_adjustiaf(freq,list_iaf,band_width)

avg_concat                      = [];

for nchan = 1:size(list_iaf,1)
    
    cfg                         = [];
    cfg.channel                 = list_iaf{nchan,1};
    freq_slct                   = ft_selectdata(cfg,freq);
    
    freq_limit                  = [list_iaf{nchan,2}-band_width list_iaf{nchan,2}+band_width];
    sub_avg{nchan}              = h_freq2avg(freq_slct,freq_limit,'avg_over_freq');
    
    avg_concat                  = [avg_concat;squeeze(sub_avg{nchan}.avg)'];
    
end

freq_adjust                     = sub_avg{1};
freq_adjust.label               = list_iaf(:,1);
freq_adjust.avg                 = avg_concat;

x                               = 0;