function h_plotStatAvgOverDimension(cfg,stat)

% plots stat that has been calculated by averaging across one dimension (
% freq or time)
% Input : stat strcuture
% cfg.ylim : y axes limits
% cfg.linewidth = line width plot
% cfg.p_threshold = to handle the mask

stat.mask                    = stat.prob < cfg.p_threshold ;

[dim_chan,dim_freq,dim_time] = size(stat.stat);

if dim_chan ==1
    
    if dim_freq == 1
        
        plot(stat.time,squeeze(stat.mask .* stat.stat),'LineWidth',cfg.linewidth);
        xlim([stat.time(1) stat.time(end)]);
        ylim([cfg.ylim(1) cfg.ylim(2)])
        
    elseif dim_time == 1
        
        plot(stat.freq,squeeze(stat.mask .* stat.stat),'LineWidth',cfg.linewidth);
        xlim([stat.freq(1) stat.freq(end)]);
        ylim([cfg.ylim(1) cfg.ylim(2)])
        
    end
    
end


