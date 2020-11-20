function stat2plot = h_plotStat2(stat,lm1,lm2)

% plots stat structure with more than 1 dimesion.
% needs to provide minimum p value to create the mask for the t-values. 

nw_stat         = stat ;
nw_stat.mask    = (nw_stat.prob > lm1 & nw_stat.prob < lm2);

stat2plot              = [];
stat2plot.label        = nw_stat.label;
stat2plot.freq         = nw_stat.freq;
stat2plot.time         = nw_stat.time;
stat2plot.dimord       = nw_stat.dimord;
stat2plot.powspctrm    = nw_stat.mask .* nw_stat.stat ;