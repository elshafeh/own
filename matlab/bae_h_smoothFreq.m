function new_data = h_smoothFreq(cfg,data)

% Function to smooth in frequency axis
% this function works for timelock and freq data
% inputs:
% cfg.freq_start : beginning of freq of interest
% cfg.freq_end : end of freq of interest
% cfg.freq_step : width of step in freq (in Hz)
% cfg.freq_window : width of smoothing window (in Hz)

% Hesham ElShafei October 3rd 2017

fprintf('Smooooooooothing ;) \n');

new_data    = data;
freq_axis   = cfg.freq_start:cfg.freq_step:cfg.freq_end;
pow         = [];

if strcmp(data.dimord,'chan_freq_time')
    
    for nt = 1:length(freq_axis)
        
        x           = find(round(data.freq)==round(freq_axis(nt)));
        y           = find(round(data.freq)==round(freq_axis(nt)+cfg.freq_window));
        data_slct   = mean(data.powspctrm(:,x:y,:),2);
        
        pow(:,nt,:) = data_slct; clear x y data_slct
        
    end
    
    new_data.powspctrm      = pow ;
    new_data.freq           = freq_axis;
    
end