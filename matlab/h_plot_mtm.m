function h_plot_mtm(cfg_in,data_in)

mtrx_data                           = [];

for ns = 1:length(data_in)
    
    cfg                             = [];
    
    if isfield(cfg_in,'channel')
        cfg.channel                 = cfg_in.channel;
    end
    
    if strcmp(cfg_in.avg,'freq')
        cfg.avgoverfreq             = 'yes';
    else
        cfg.avgovertime             = 'yes';
    end
    
    cfg.avgoverchan                 = 'yes';
    data_nw{ns}                     = ft_selectdata(cfg,data_in{ns});
    
    mtrx_data(ns,:)                 = squeeze(data_nw{ns}.powspctrm);
    
    clc;
    
end

% Use the standard deviation over trials as error bounds:
mean_data                           = nanmean(mtrx_data,1);
bounds                              = nanstd(mtrx_data, [], 1);
bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));

if strcmp(cfg_in.avg,'freq')
    time_axs                        = data_nw{1}.time;
else
    time_axs                        = data_nw{1}.freq;
end

if strcmp(cfg_in.plotsingle,'yes')
    plot(time_axs, mtrx_data, 'Color', [0.8 0.8 0.8]);
end

boundedline(time_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent

% Add all our previous improvements:
if strcmp(cfg_in.avg,'freq')
    xlabel('Time (s)');
else
    xlabel('Frequency (Hz)');
end

ylabel('Power');
ax                  = gca();
ax.TickDir          = 'out';
box off;

xlim(cfg_in.xlim);
hline(0,'--k');

if isfield(cfg_in,'ylim')
    ylim(cfg_in.ylim);
end

if isfield(cfg_in,'vline')
    for n = 1: length(cfg_in.vline)
        vline(cfg_in.vline(n),'--k');
    end
end