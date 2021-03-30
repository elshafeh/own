clear; close all;

suj_list                            = dir('P:\3035002.01\localizer\MEG\*.ds');
interpolate_window                  = [0.005 0.015];

for nsuj = 1:4 %length(suj_list)
    
    dsFileName                      = [suj_list(nsuj).folder filesep suj_list(nsuj).name];
    
    cfg                             = [];
    cfg.dataset                     = dsFileName;
    cfg.trialfun                    = 'ft_trialfun_general';
    cfg.trialdef.eventtype          = 'backpanel trigger';
    cfg.trialdef.eventvalue         = [64 128];
    cfg.trialdef.prestim            = 0.5;
    cfg.trialdef.poststim           = 0.5;
    cfg                             = ft_definetrial(cfg);
    
    cfg.channel                     = {'MEG'}; %{'M*T*' 'M*P*' 'M*C*'};
    cfg.continuous                  = 'yes';
    cfg.precision                   = 'single';
    data{nsuj,1}                  	= ft_preprocessing(cfg);
    
    data{nsuj,2}                    = h_interpolatespike(data{nsuj,1},interpolate_window,'spline');
    data{nsuj,3}                    = h_interpolatespike(data{nsuj,1},interpolate_window,'mean');
    data{nsuj,4}                    = h_interpolatespike(data{nsuj,1},interpolate_window,'nan');

end

%%

keep data suj_list interpolate_window

nsuj                                = size(data,1);

iplot                               = 0;
nrow                                = nsuj;
ncol                                = size(data,2);

for nsuj = 1:nsuj
    
    avg                             = ft_timelockanalysis([],data{nsuj,1});
    cfg                             = [];
    cfg.latency                     = interpolate_window;
    cfg.avgovertime                 = 'yes';
    avg                             = ft_selectdata(cfg,avg);
    
    % define arbitrary window
    mtrx                            = abs(avg.avg);
    
    % find max in space
    nb_max_chan                     = 1;
    vctr                         	= [[1:length(mtrx)]' mtrx];
    vctr_sort                   	= sortrows(vctr,2,'descend'); % sort from high to low
    max_chan_label               	= avg.label(vctr_sort(1:nb_max_chan,1)); % take 5 max channels
    max_chan_index               	= vctr_sort(1:nb_max_chan,1);
    
    list_cond                       = {'no' 'spline' 'mean' 'nan'};
    
    for ncond = 1:size(data,2)
        
        avg                         = ft_timelockanalysis([],data{nsuj,ncond});
        
        if ncond == 1
            ax_min                	= min(mean(avg.avg(max_chan_index,:),1));
            ax_max                	= max(mean(avg.avg(max_chan_index,:),1));
        end
        
        x_lim                     	= [-0.2 0.2];
        y_lim                     	= [ax_min ax_max];
        
        list_color                  = 'brkm';
        
        iplot                     	= iplot+1;
        subplot(nrow,ncol,iplot); hold on;
        plot(avg.time,mean(avg.avg(max_chan_index,:),1),['-' list_color(ncond)]);
        xlim(x_lim); 
        ylim(y_lim); 
        yticks([]);
        title(['sub' num2str(nsuj) ' max chan ' list_cond{ncond} ' interpolation']);
        %         rectangle('Position',[interpolate_window(1) ax_min diff(interpolate_window) abs(ax_min)+abs(ax_max)],'Curvature',0.2)
        %         vline(0,'--k');
        
    end
end