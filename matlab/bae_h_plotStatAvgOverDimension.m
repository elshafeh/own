function h_plotStatAvgOverDimension(cfg,stat,avg_data_1,avg_data_2)

% function to plot any data that is 1 x time with significant time-periods
% marked by a rectangle
% cfg.p_threshold : limit to mask stat structure
% cfg.lineWidth : width of line to be plot
% cfg.x_limit : to adjust the x-axes (time)
% cfg.z_limit : to adjust the y-axes
% cfg.legend

% cfg.avgover       = 'freq' or 'time
% cfg.dim_list      = [x1 x2]
% cfg.channel

new_stat.freq       = stat.freq;
new_stat.time       = stat.time;
new_stat.label      = stat.label;
new_stat.dimord     = stat.dimord;

stat.mask           = stat.prob < cfg.p_threshold;

new_stat.powspctrm  = stat.mask .* stat.stat;


t_cfg               = [];
t_cfg.channel       = cfg.channel;

if iscell(t_cfg.channel)
    t_cfg.avgoverchan = 'yes';
end

new_stat            = ft_selectdata(t_cfg,new_stat);

if strcmp(cfg.avgover,'freq')
    t_cfg.frequency   = cfg.dim_list;
    t_cfg.avgoverfreq   = 'yes';
    
    time_axes           = stat.time;
    time_axes           = [time_axes; zeros(1,length(time_axes))];
    
else
    t_cfg.latency     = cfg.dim_list;
    t_cfg.avgovertime   = 'yes';
    
    
    time_axes           = stat.freq;
    time_axes           = [time_axes; zeros(1,length(time_axes))];
    
end

avg_data_1          = ft_selectdata(t_cfg,avg_data_1);
avg_data_2          = ft_selectdata(t_cfg,avg_data_2);


avg_data_1.avg      = squeeze(avg_data_1.powspctrm)';
avg_data_2.avg      = squeeze(avg_data_2.powspctrm)';
new_stat.avg        = squeeze(new_stat.powspctrm)';

avg_data_1          = rmfield(avg_data_1,'powspctrm');
avg_data_2          = rmfield(avg_data_2,'powspctrm');
new_stat            = rmfield(new_stat,'powspctrm');

avg_data_1.dimord   = 'chan_time';
avg_data_2.dimord   = 'chan_time';
new_stat.dimord     = 'chan_time';

pow                 = new_stat.avg;

hold on;

for nt = 1:length(time_axes)
    
    if time_axes(2,nt) ~= 1
        
        if pow(nt) ~= 0
            
            rec_start       = time_axes(1,nt);
            
            time_axes(2,nt) = 1;
            
            flg             = 0;
            xp              = 1;
            
            while flg == 0
                
                if nt+xp <= size(time_axes,2)
                    if time_axes(2,nt+xp) ~= 1
                        
                        if pow(nt+xp) ~= 0
                            time_axes(2,nt+xp) = 1;
                            xp = xp + 1 ;
                        else
                            flg     = 1 ;
                            rec_end =  time_axes(1,nt+xp-1) ;
                        end
                        
                    else
                        
                        flg     = 1 ;
                        rec_end =  time_axes(1,nt+xp-1) ;
                        
                    end
                else
                    flg     = 1 ;
                    rec_end =  time_axes(1,nt+xp-1);
                end
                
            end
            
            rec_width = abs(cfg.z_limit(2)) + abs(cfg.z_limit(1)); 
            
            rectangle('Position',[rec_start,cfg.z_limit(1),rec_end-rec_start,rec_width],'FaceColor',[0.95 0.95 0.95])
            
        end 
    end
end

if strcmp(cfg.avgover,'freq')
    
    plot(avg_data_1.time,avg_data_1.avg,'LineWidth',cfg.lineWidth)
    xlim(cfg.x_limit)
    ylim(cfg.z_limit)
    
    plot(avg_data_2.time,avg_data_2.avg,'LineWidth',cfg.lineWidth)
    xlim(cfg.x_limit)
    ylim(cfg.z_limit)
    
else
    
    plot(avg_data_1.freq,avg_data_1.avg,'LineWidth',cfg.lineWidth)
    xlim(cfg.x_limit)
    ylim(cfg.z_limit)
    
    plot(avg_data_2.freq,avg_data_2.avg,'LineWidth',cfg.lineWidth)
    xlim(cfg.x_limit)
    ylim(cfg.z_limit)
    
end


clc;
legend(cfg.legend)
