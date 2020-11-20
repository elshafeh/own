function h_plot_fft(cfg_in,data_in)

mtrx_data                           = [];

for ns = 1:length(data_in)
    
    cfg                             = [];
    
    if isfield(cfg_in,'channel')
        cfg.channel                     = cfg_in.channel;
    end
    
    cfg.avgoverchan                 = 'yes';
    data_nw{ns}                     = ft_selectdata(cfg,data_in{ns});
    
    mtrx_data(ns,:)                 = squeeze(data_nw{ns}.powspctrm);
    
end

% Use the standard deviation over trials as error bounds:
mean_data                           = mean(mtrx_data,1);
bounds                              = std(mtrx_data, [], 1);
bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));

time_axs                            = data_nw{1}.freq;

if strcmp(cfg_in.plotsingle,'yes')
    plot(time_axs, mtrx_data, 'Color', [0.8 0.8 0.8]);
end

boundedline(time_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent

% Add all our previous improvements:
xlabel('Time (s)');
ylabel('Power');
ax                  = gca();
ax.XAxisLocation    = 'origin';
ax.YAxisLocation    = 'origin';
ax.TickDir          = 'out';
box off;
ax.XLabel.Position(2) = -60;

xlim(cfg_in.xlim);

if isfield(cfg_in,'ylim')
    ylim(cfg_in.ylim);
end

% if isfield(cfg_in,'vline')
%     for n = 1: length(cfg_in.vline)
%         vline(cfg_in.vline(n),'--k');
%     end
% end
%
% if isfield(cfg_in,'rect_ax')
%     for n = 1:size(cfg_in.rect_ax,1)
%
%         rec_start   = cfg_in.rect_ax(n,1);
%         rec_end     = cfg_in.rect_ax(n,2);
%
%         rec_width   = abs(ax.YLim(1))+abs(ax.YLim(2));
%
%         rectangle('Position',[rec_start,ax.YLim(1),rec_end-rec_start,rec_width],'FaceColor', [0 0 0.05 0.05])
%
%     end
% end