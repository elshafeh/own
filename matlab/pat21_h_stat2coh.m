function coh2plot = h_stat2coh(stat,p_threshold1,p_threshold2)

nw_stat               = stat ;
mask1                 = nw_stat.prob < p_threshold2;
mask2                 = nw_stat.prob > p_threshold1;

nw_stat.mask          = mask1 .* mask2;

coh2plot              = [];
coh2plot.label        = nw_stat.label;
coh2plot.freq         = nw_stat.freq;
coh2plot.dimord       = 'chan_chan_freq';
coh2plot.cohspctrm    = nw_stat.mask .* nw_stat.stat ;