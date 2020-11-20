function stat2plot = h_plotStat(stat,p_threshold1,p_threshold2)

% plots stat structure with more than 1 dimesion.
% needs to provide minimum p value to create the mask for the t-values. 

nw_stat                 = stat ;
mask1                   = nw_stat.prob < p_threshold2;
mask2                   = nw_stat.prob > p_threshold1;

nw_stat.mask            = mask1 .* mask2;

if strcmp(stat.dimord,'chan_freq_time')
    
    stat2plot              = [];
    stat2plot.label        = nw_stat.label;
    stat2plot.freq         = nw_stat.freq;
    stat2plot.time         = nw_stat.time;
    stat2plot.dimord       = nw_stat.dimord;
    
    if isfield(stat,'rho')
        stat2plot.powspctrm    = nw_stat.mask .* nw_stat.rho ;
    else
        stat2plot.powspctrm    = nw_stat.mask .* nw_stat.stat ;
    end
    
else
    
    stat2plot              = [];
    stat2plot.label        = nw_stat.label;
    stat2plot.time         = nw_stat.time;
    stat2plot.dimord       = nw_stat.dimord;
    stat2plot.avg          = nw_stat.mask .* nw_stat.stat ;

end

    

% if strcmp(yn,'yes')    
%     figure;
%     cfg             = [];
%     cfg.layout      = 'CTF275.lay';
%     cfg.zlim        = [-4 4];
%     ft_multiplotTFR(cfg,stat2plot);
% end


