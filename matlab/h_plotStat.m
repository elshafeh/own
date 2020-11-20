function stat2plot = h_plotStat(stat,p_threshold1,p_threshold2,params)

% plots stat structure with more than 1 dimesion.
% needs to provide minimum p value to create the mask for the t-values

nw_stat                 = stat ;
mask1                   = nw_stat.prob < p_threshold2;
mask2                   = nw_stat.prob > p_threshold1;

nw_stat.mask            = mask1 .* mask2;

if strcmp(stat.dimord,'chan_freq_time')
    
    [dim_chan,dim_freq,dim_time] = size(nw_stat.stat);
    
    if dim_freq ~=1 && dim_time ~= 1
        
        stat2plot              = [];
        stat2plot.label        = nw_stat.label;
        stat2plot.freq         = nw_stat.freq;
        stat2plot.time         = nw_stat.time;
        stat2plot.dimord       = nw_stat.dimord;
        
        if isfield(stat,'rho')
            stat2plot.powspctrm    = nw_stat.mask .* nw_stat.rho ;
        else
            if strcmp(params,'stat')
                stat2plot.powspctrm    = nw_stat.mask .* nw_stat.stat ;
            elseif strcmp(params,'prob')
                stat2plot.powspctrm    = nw_stat.mask .* nw_stat.prob ;
            end
        end
        
    else
        
        stat2plot              = [];
        stat2plot.label        = nw_stat.label;
        stat2plot.dimord       = 'chan_time';
        
        if dim_freq  == 1
            stat2plot.time = nw_stat.time;
        elseif dim_time == 1
            stat2plot.time = nw_stat.freq;
        end
        
        if strcmp(params,'stat')
            stat2plot.avg    = squeeze(nw_stat.mask .* nw_stat.stat);
        elseif strcmp(params,'prob')
            stat2plot.avg    = squeeze(nw_stat.mask .* nw_stat.prob);
        end
        
    end
    
elseif strcmp(stat.dimord,'chan_time')
    
    stat2plot              = [];
    stat2plot.label        = nw_stat.label;
    stat2plot.time         = nw_stat.time;
    stat2plot.dimord       = nw_stat.dimord;
    
    if strcmp(params,'stat')
        stat2plot.avg    = squeeze(nw_stat.mask .* nw_stat.stat);
    elseif strcmp(params,'prob')
        stat2plot.avg    = squeeze(nw_stat.mask .* nw_stat.prob);
    elseif strcmp(params,'rho')
        stat2plot.avg    = squeeze(nw_stat.mask .* nw_stat.rho);
    end
    
end