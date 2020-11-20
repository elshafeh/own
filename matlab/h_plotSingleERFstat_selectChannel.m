function h_plotSingleERFstat_selectChannel(cfg_in,stat,data_in)

%,avg_data_1,avg_data_2)

% function to plot any data that is 1 x time with significant time-periods
% marked by a rectangle

% cfg.channel
% cfg.p_threshold : limit to mask stat structure
% cfg.lineWidth : width of line to be plot
% cfg.time_limit : to adjust the x-axes (time)
% cfg.z_limit : to adjust the y-axes
% cfg.legend
% cfg.color

mtrx_data                               = [];

for ns = 1:size(data_in,1)
    for ncon = 1:size(data_in,2)
        
        if iscell(cfg_in.channel)
            find_chan                   = [];
            for ni = 1:length(cfg_in.channel)
            find_chan               	= [find_chan;find(strcmp(cfg_in.channel{ni},data_in{ns,ncon}.label))];
            end
        else
            find_chan                   = find(strcmp(cfg_in.channel,data_in{ns,ncon}.label));
        end
        
        find_t1                         = find(round(data_in{ns,ncon}.time,2) == round(stat.time(1),2));
        find_t2                         = find(round(data_in{ns,ncon}.time,2) == round(stat.time(end),2));
        
        data                            = nanmean(data_in{ns,ncon}.avg(find_chan,find_t1:find_t2),1);
        
        mtrx_data(ns,ncon,:)           	= data; clear data;
        
    end
end

if ~isfield(cfg_in,'z_limit')
    cfg_in.z_limit 	= [-max(max(nanmax(abs(mtrx_data)))) max(max(nanmax(abs(mtrx_data))))];
end

stat.mask           = stat.prob < cfg_in.p_threshold;

new_stat            = [];
new_stat.dimord     = stat.dimord;
new_stat.avg        = stat.mask .* stat.prob;
new_stat.time       = stat.time;
new_stat.label      = stat.label;

t_cfg               = [];
t_cfg.channel       = cfg_in.channel;

if iscell(t_cfg.channel)
    t_cfg.avgoverchan = 'yes';
end

new_stat            = ft_selectdata(t_cfg,new_stat);

time_axes           = stat.time;
time_axes           = [time_axes; zeros(1,length(time_axes))];

stat.mask           = stat.prob < cfg_in.p_threshold;
pow                 = new_stat.avg;

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
            
            if cfg_in.z_limit(1) >= 0
                rec_width = abs(cfg_in.z_limit(2)) - abs(cfg_in.z_limit(1));
            else
                rec_width = abs(cfg_in.z_limit(2)) + abs(cfg_in.z_limit(1));
            end
            
            rectangle('Position',[rec_start,cfg_in.z_limit(1),rec_end-rec_start,rec_width],'FaceColor',[0.95 0.95 0.95])
            
        end 
    end
end


% Use the standard deviation over trials as error bounds:

for ncon = 1:size(data_in,2)
    
    tmp                                 = squeeze(mtrx_data(:,ncon,:));
    
    mean_data                           = nanmean(tmp,1);
    bounds                              = nanstd(tmp, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(tmp,1));
    
    boundedline(stat.time, mean_data, bounds_sem,['-' cfg_in.color(ncon)],'alpha'); % alpha makes bounds transparent
    
    clear mean_data bounds_sem bounds
end

ylim(cfg_in.z_limit);
xlim(cfg_in.time_limit);

yticks(cfg_in.z_limit);