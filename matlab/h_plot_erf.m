function h_plot_erf(cfg_in,data_in)

% input 
% cfg.channel

mtrx_data                               = [];

for ns = 1:size(data_in,1)
    for ncon = 1:size(data_in,2)
        
        if iscell(cfg_in.label)
            find_chan                   = [];
            for ni = 1:length(cfg_in.label)
            find_chan               	= [find_chan;find(strcmp(cfg_in.label{ni},data_in{ns,ncon}.label))];
            end
        else
            find_chan                   = 1;
        end
        
        switch data_in{ns,ncon}.dimord
            case 'chan_time'
                data_type                   = 'time';
                data                    	= nanmean(data_in{ns,ncon}.avg(find_chan,:),1);
            case 'chan_freq'
                data_type                   = 'freq';
                data                    	= nanmean(data_in{ns,ncon}.powspctrm(find_chan,:),1);
        end
                
        mtrx_data(ns,ncon,:)           	= data; clear data;
        
    end
end

if isfield(cfg_in,'zerolim')
    if strcmp(cfg_in.zerolim,'minzero')
        mtrx_data(mtrx_data>0) = NaN;
    elseif strcmp(cfg_in.zerolim,'zeromax')
        mtrx_data(mtrx_data<0) = NaN;
    end
end

% Use the standard deviation over trials as error bounds:

switch data_type
    case 'time'
        time_axs                        = data_in{1}.time;
    case 'freq'
        time_axs                        = data_in{1}.freq;
end

hold on;

for ncon = 1:size(data_in,2)
    
    tmp                                 = squeeze(mtrx_data(:,ncon,:));
    
    mean_data                           = nanmean(tmp,1);
    bounds                              = nanstd(tmp, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(tmp,1));
    
    boundedline(time_axs, mean_data, bounds_sem,['-' cfg_in.color(ncon)],'alpha'); % alpha makes bounds transparent
    
    clear mean_data bounds_sem bounds
    
    if isfield (cfg_in,'plot_single')
        if strcmp(cfg_in.plot_single,'yes')
            plot(time_axs, tmp, 'Color', [0.8 0.8 0.8]);
        end
    end
    
end


if isfield(cfg_in,'xlim')
    
    xlim(cfg_in.xlim);
    
    %     t1              = find(round(cfg_in.xlim(1),2) == round(time_axs,2));
    %     t2              = find(round(cfg_in.xlim(2),2) == round(time_axs,2));
    %     mean_data       = mean_data(t1:t2);
    %     time_axs        = time_axs(t1:t2);
    
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


if isfield(cfg_in,'plot_max')
    for nm = 1:cfg_in.plot_max
        
        fnd_max                 = find(mean_data==max(mean_data));
        max_data                = time_axs(fnd_max);
        mean_data(fnd_max)      = 0;
        
        vline(max_data,'--k');
        
    end 
end