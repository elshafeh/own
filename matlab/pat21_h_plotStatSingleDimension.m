function stat2plot = h_plotStatSingleDimension(stat,p_threshold1,p_threshold2)

nw_stat                 = stat ;
mask1                   = nw_stat.prob < p_threshold2;
mask2                   = nw_stat.prob > p_threshold1;

nw_stat.mask            = mask1 .* mask2;

stat2plot              = [];
stat2plot.label        = nw_stat.label;
stat2plot.freq         = nw_stat.freq;
stat2plot.time         = nw_stat.time;
stat2plot.dimord       = nw_stat.dimord;
stat2plot.powspctrm    = nw_stat.mask .* nw_stat.stat ;

ix                     = find(stat2plot.powspctrm ~=0);
tmp                    = squeeze(mean(stat2plot.powspctrm(ix,:,:),1));
stat2plot.powspctrm    = tmp; clear tmp ix ;