function h_plotSingleERFstat_selectChannel(cfg,stat,avg_data_1,avg_data_2)

% function to plot any data that is 1 x time with significant time-periods
% marked by a rectangle
% cfg.p_threshold : limit to mask stat structure
% cfg.lineWidth : width of line to be plot
% cfg.time_limit : to adjust the x-axes (time)
% cfg.z_limit : to adjust the y-axes
% cfg.legend

stat.mask           = stat.prob < cfg.p_threshold;

new_stat            = [];
new_stat.dimord     = stat.dimord;
new_stat.avg        = stat.mask .* stat.stat;
new_stat.time       = stat.time;
new_stat.label      = stat.label;

t_cfg         = [];
t_cfg.channel = cfg.channel;

if iscell(t_cfg.channel)
    t_cfg.avgoverchan = 'yes';
end

new_stat        = ft_selectdata(t_cfg,new_stat);

avg_data_1      = ft_selectdata(t_cfg,avg_data_1);
avg_data_2      = ft_selectdata(t_cfg,avg_data_2);

time_axes       = stat.time;
time_axes       = [time_axes; zeros(1,length(time_axes))];

stat.mask       = stat.prob < cfg.p_threshold;

pow             = new_stat.avg;

hold on;

for nt = 1:length(time_axes)
    
    if time_axes(2,nt) ~= 1
        
        if pow(1,nt) ~= 0
            
            rec_start       = time_axes(1,nt);
            
            time_axes(2,nt) = 1;
            
            flg             = 0;
            xp              = 1;
            
            while flg == 0
                
                if nt+xp <= size(time_axes,2)
                    if time_axes(2,nt+xp) ~= 1
                        
                        if pow(1,nt+xp) ~= 0
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

    
plot(avg_data_1.time,avg_data_1.avg,'LineWidth',cfg.lineWidth)
xlim(cfg.time_limit)
ylim(cfg.z_limit)

plot(avg_data_2.time,avg_data_2.avg,'LineWidth',cfg.lineWidth)
xlim(cfg.time_limit)
ylim(cfg.z_limit)

clc;

% legend(cfg.legend)
% set(findall(gcf,'-property','FontSize'),'FontSize',cfg.fontSize)