function stat2plot = h_plotmyERFstat(stat,p_value)

% creates a structure that can ben viewed easily by fieldtrip
% p_value is your threshold ; anything higher that it will be masked

stat.mask             = stat.prob < p_value ;
stat2plot.time        = stat.time;
stat2plot.label       = stat.label;
stat2plot.avg         = stat.stat .* stat.mask;
stat2plot.dimord      = 'chan_time';
