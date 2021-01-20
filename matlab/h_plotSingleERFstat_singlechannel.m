function h_plotSingleERFstat_singlechannel(cfg_in,stat_in,data_in)

%,avg_data_1,avg_data_2)

% function to plot any data that is 1 x time with significant time-periods
% marked by a rectangle

% cfg.lineWidth : width of line to be plot
% cfg.time_limit : to adjust the x-axes (time)
% cfg.z_limit : to adjust the y-axes
% cfg.legend
% cfg.color

stat                                    = [];
stat.mask                               = stat_in.mask;
stat.time                               = stat_in.time; clear stat_in;

mtrx_data                               = [];

for ns = 1:size(data_in,1)
    for ncon = 1:size(data_in,2)
        
        mtrx_data(ns,ncon,:)           	= squeeze(data_in{ns,ncon}.avg); clear data tmp; clc;
        
    end
end

mtrx_data                               = squeeze(mtrx_data);

if ~isfield(cfg_in,'z_limit')
    cfg_in.z_limit 	= [-max(max(nanmax(abs(mtrx_data)))) max(max(nanmax(abs(mtrx_data))))];
end

hold on;

% Use the standard deviation over trials as error bounds:
for ncon = 1:size(data_in,2)
    
    tmp                                 = squeeze(mtrx_data(:,ncon,:));
    
    mean_data                           = nanmean(tmp,1);
    bounds                              = nanstd(tmp, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(tmp,1));
    
    boundedline(data_in{ns,ncon}.time, mean_data, bounds_sem,cfg_in.color{ncon},'alpha'); % alpha makes bounds transparent

    clear mean_data bounds_sem bounds
end

if isfield(cfg_in,'z_limit')
    ylim(cfg_in.z_limit);
    yticks(cfg_in.z_limit);
end

if isfield(cfg_in,'time_limit')
    xlim(cfg_in.time_limit);
end

hold on;

ax	= gca;
lm  = ax.YAxis.Limits(end);

if size(stat.mask,1) == 1
    plot_vct                    = double(stat.mask);
    plot_vct(plot_vct == 1)     = lm;
    plot_vct(plot_vct == 0)     = NaN;
else
    plot_vct                    = mean(double(stat.mask),1);
    plot_vct(plot_vct ~= 0)     = lm;
    plot_vct(plot_vct == 0)     = NaN;
end

plot(stat.time,plot_vct,'k','LineWidth',cfg_in.linewidth);