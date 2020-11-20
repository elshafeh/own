function new_data = h_smoothTime(cfg,data)

% Function to smooth in time axis
% this function works for timelock and freq data
% inputs:
% cfg.time_start : beginning of period of interest (in seconds)
% cfg.time_end : end of period of interest (in seconds)
% cfg.time_step : width of step in time (in seconds)
% cfg.time_window : width of smoothing window (in seconds)

% Hesham ElShafei October 3rd 2017

new_data    = data;
time_axis   = cfg.time_start:cfg.time_step:cfg.time_end;
pow         = [];

if strcmp(data.dimord,'chan_time')
   
    for nt = 1:length(time_axis)
    
        x           = find(round(data.time,4)==round(time_axis(nt),4));
        y           = find(round(data.time,4)==round(time_axis(nt)+cfg.time_window,4));
        data_slct   = mean(data.avg(:,x:y),2);
        
        pow         = [pow data_slct]; clear x y data_slct
        
    end
    
    new_data.avg    = pow ;
    new_data.time   = time_axis; 
    
elseif strcmp(data.dimord,'chan_freq_time')
    
    for nt = 1:length(time_axis)
        
        x           = find(round(data.time,4)==round(time_axis(nt),4));
        y           = find(round(data.time,4)==round(time_axis(nt)+cfg.time_window,4));
        data_slct   = mean(data.powspctrm(:,:,x:y),3);
        
        pow(:,:,nt) = data_slct; clear x y data_slct
        
    end
    
    new_data.powspctrm      = pow ;
    new_data.time           = time_axis;
    
elseif strcmp(data.dimord,'chan_chan_freq_time') || strcmp(data.dimord,'rpt_chan_freq_time')

    for nt = 1:length(time_axis)
        
        x               = find(round(data.time,4)==round(time_axis(nt),4));
        y               = find(round(data.time,4)==round(time_axis(nt)+cfg.time_window,4));
        data_slct       = mean(data.powspctrm(:,:,:,x:y),4);
        
        pow(:,:,:,nt)   = data_slct; clear x y data_slct
        
    end
    
    new_data.powspctrm      = pow ;
    new_data.time           = time_axis;
    
end