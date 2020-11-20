function h_plot_erf(cfg_in,data_in)

mtrx_data                           = [];

for ns = 1:length(data_in)
    
    if isfield(cfg_in,'label')
        
        %         cfg                             = [];
        %         cfg.channel                     = cfg_in.label;
        %         cfg.avgoverchan                 = 'yes';
        %         data_nw{ns}                     = ft_selectdata(cfg,data_in{ns});
        
        data_nw{ns}                     = data_in{ns};
        data_nw{ns}.avg                 = data_nw{ns}.avg(cfg_in.label,:);
        data_nw{ns}.label               = data_nw{ns}.label(cfg_in.label);
        
    else
        data_nw{ns}                     = data_in{ns};
    end
    
    mtrx_data(ns,:)                     = data_nw{ns}.avg;
    
end

if isfield(cfg_in,'zerolim')
    if strcmp(cfg_in.zerolim,'minzero')
        mtrx_data(mtrx_data>0) = NaN;
    elseif strcmp(cfg_in.zerolim,'zeromax')
        mtrx_data(mtrx_data<0) = NaN;
    end
end

% Use the standard deviation over trials as error bounds:
mean_data                           = nanmean(mtrx_data,1);
bounds                              = nanstd(mtrx_data, [], 1);
bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));

time_axs                            = data_nw{1}.time;

if strcmp(cfg_in.plot_single,'yes')
    plot(time_axs, mtrx_data, 'Color', [0.8 0.8 0.8]);
end

if isfield (cfg_in,'color')
    boundedline(time_axs, mean_data, bounds_sem,['-' cfg_in.color],'alpha'); % alpha makes bounds transparent
else
    boundedline(time_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent
end

% Add all our previous improvements:
% xlabel('Time (s)');
% ylabel('Magnetic gradient (fT)');
% ax                  = gca();
% ax.XAxisLocation    = 'origin';
% ax.YAxisLocation    = 'origin';
% ax.TickDir          = 'out';
% box off;
% ax.XLabel.Position(2) = -60;

if isfield(cfg_in,'xlim')
    xlim(cfg_in.xlim);
end

if isfield(cfg_in,'ylim')
    ylim(cfg_in.ylim);
end

if isfield(cfg_in,'vline')
    for n = 1: length(cfg_in.vline)
        vline(cfg_in.vline(n),'--k');
    end
end

if isfield(cfg_in,'hline')
    for n = 1: length(cfg_in.hline)
        hline(cfg_in.hline(n),'--k');
    end
end

if isfield(cfg_in,'rect_ax')
    for n = 1:size(cfg_in.rect_ax,1)
        
        rec_start   = cfg_in.rect_ax(n,1);
        rec_end     = cfg_in.rect_ax(n,2);
        
        rec_width   = abs(ax.YLim(1))+abs(ax.YLim(2));
        
        rectangle('Position',[rec_start,ax.YLim(1),rec_end-rec_start,rec_width],'FaceColor', [0 0 0.05 0.05])
        
    end
end