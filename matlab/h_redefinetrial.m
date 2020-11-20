function new_data = h_redefinetrial(cfg,data)

% cfg.window : time in ses before and after
% cfg.begsample : how many samples apart the new-event is from the 0 (e.g.
% RT = 0.34 ms then begsample is (Fs .* RT) or whatever the correct
% forumlua is :D

% use as:
% cfg                                     = [];
% cfg.window                              = new_time_window;
% cfg.begsample                           = offset.target;
% both values for window should be positive


new_data                    = data;

for nt = 1:length(new_data.trial)
    
    % this is important
    find_zero               = find(round(new_data.time{nt},4) == round(0,4));
    
    if isempty(find_zero)
        find_zero           = find(round(data.time{nt},3) == round(0,3));
    end
    
    if isempty(find_zero)
        find_zero           = find(round(data.time{nt},2) == round(0,2));
    end
    
    ix_start                = (find_zero+cfg.begsample(nt)) - cfg.window(1)*data.fsample;
    ix_end                  = (find_zero+cfg.begsample(nt)) + cfg.window(2)*data.fsample;
    
    sin_trl                 = new_data.trial{nt}(:,ix_start:ix_end);
    sin_time                = -cfg.window(1):1/data.fsample:cfg.window(2);
    
    new_data.trial{nt}      = sin_trl;
    new_data.time{nt}       = sin_time;
    
end

new_data                    = rmfield(new_data,'sampleinfo');