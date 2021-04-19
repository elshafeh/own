function h_plotSingleERFstat_selectChannel_nobox(cfg_in,stat_in,data_in)

%,avg_data_1,avg_data_2)

% function to plot any data that is 1 x time with significant time-periods
% marked by a rectangle

% cfg.channel
% cfg.lineWidth : width of line to be plot
% cfg.time_limit : to adjust the x-axes (time)
% cfg.z_limit : to adjust the y-axes
% cfg.legend
% cfg.color

if iscell(cfg_in.channel)
    find_chan_in_stat = [];
    for nc = 1:length(cfg_in.channel)
        find_chan_in_stat            	= [find_chan_in_stat; find(strcmp(cfg_in.channel{nc},stat_in.label))];
    end
else
    find_chan_in_stat                   = cfg_in.channel;
end

stat                                    = [];
stat.mask                               = stat_in.mask(find_chan_in_stat,:);
stat.time                               = stat_in.time; clear stat_in;

mtrx_data                               = [];

for ns = 1:size(data_in,1)
    for ncon = 1:size(data_in,2)
        
        if ~iscell(cfg_in.channel)
            
            %             t1              = nearest(data_in{ns,ncon}.time,stat.time(1));
            %             t2              = nearest(data_in{ns,ncon}.time,stat.time(end));
            %             t1              = t1(1);
            %             t2              = t2(1);
            
            t1              = 1;
            t2              = length(data_in{ns,ncon}.time);
            
            tmp             = data_in{ns,ncon}.avg(cfg_in.channel,t1:t2);
            data           	= nanmean(tmp,1);
            
        else
            
            %             t1              = nearest(data_in{ns,ncon}.time,stat.time(1));
            %             t2              = nearest(data_in{ns,ncon}.time,stat.time(end));
            %             t1              = t1(1);
            %             t2              = t2(1);
            
            t1              = 1;
            t2              = length(data_in{ns,ncon}.time);

            find_chan_in_data = [];
            for nc = 1:length(cfg_in.channel)
                find_chan_in_data            	= [find_chan_in_data; find(strcmp(cfg_in.channel{nc},data_in{ns,ncon}.label))];
            end
            
            tmp             = data_in{ns,ncon}.avg(find_chan_in_data,t1:t2);
            data           	= nanmean(tmp,1);
            
        end
        
        mtrx_data(ns,ncon,:)           	= squeeze(data); clear data tmp; %clc;
        
    end
end

mtrx_data                               = squeeze(mtrx_data);

if ~isfield(cfg_in,'z_limit')
    cfg_in.z_limit 	= [-max(max(nanmax(abs(mtrx_data)))) max(max(nanmax(abs(mtrx_data))))];
end

% t_cfg               = [];
% t_cfg.channel       = cfg_in.channel;
% if iscell(t_cfg.channel)
%     t_cfg.avgoverchan = 'yes';
% end
% new_stat            = ft_selectdata(t_cfg,stat);

hold on;

% Use the standard deviation over trials as error bounds:
for ncon = 1:size(data_in,2)
    
    if size(data_in,2) > 1
        tmp                                 = squeeze(mtrx_data(:,ncon,:));
    else
        tmp                                 = mtrx_data;
    end
    
    mean_data                           = nanmean(tmp,1);
    bounds                              = nanstd(tmp, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(tmp,1));
    x_axis                              = data_in{1}.time;
    
    if iscell(cfg_in.color)
        boundedline(x_axis, mean_data, bounds_sem,cfg_in.color{ncon},'alpha'); % alpha makes bounds transparent     
    else
        boundedline(x_axis, mean_data, bounds_sem,'cmap',cfg_in.color(ncon,:),'alpha'); % alpha makes bounds transparent
    end
    
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
    
    plot_vct                    = nan(1,length(data_in{1}.time));
    t1                          = nearest(data_in{1}.time,stat.time(1));
    t2                          = nearest(data_in{1}.time,stat.time(end));
    plot_vct(t1:t2)             = double(stat.mask);
    plot_vct(plot_vct == 1)     = lm;
    plot_vct(plot_vct == 0)     = NaN;
    
else
    
    plot_vct                    = mean(double(stat.mask),1);
    plot_vct(plot_vct ~= 0)     = lm;
    plot_vct(plot_vct == 0)     = NaN;

    x_axis                      = stat.time;
    
    %     plot_vct                    = nan(1,length(data_in{1}.time));
    %     t1                          = nearest(data_in{1}.time,stat.time(1));
    %     t2                          = nearest(data_in{1}.time,stat.time(end));
    %     plot_vct(t1:t2)           	= mask_vector;
        
end

plot(x_axis,plot_vct,cfg_in.lineshape,'LineWidth',cfg_in.linewidth);
x                               = 0;