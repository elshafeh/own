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

new_data                        = data;
new_data                        = rmfield(new_data,'trial');
new_data                        = rmfield(new_data,'time');
new_data                        = rmfield(new_data,'trialinfo');

if isfield(new_data,'sampleinfo')
    new_data                 	= rmfield(new_data,'sampleinfo');
end

i                               = 0;

for nt = 1:length(data.trial)
    
    % this is important
    find_zero                   = nearest(data.time{nt},0);
    
    ix_start                    = (find_zero+cfg.begsample(nt)) - cfg.window(1)*data.fsample;
    ix_end                      = (find_zero+cfg.begsample(nt)) + cfg.window(2)*data.fsample;
    
    if ix_end <= length(data.trial{nt})
        
        i                       = i + 1;
        
        sin_trl                 = data.trial{nt}(:,ix_start:ix_end);
        sin_time                = -cfg.window(1):1/data.fsample:cfg.window(2);
        
        new_data.trial{i}       = sin_trl;
        new_data.time{i}        = sin_time;
        new_data.trialinfo(i,:)	= data.trialinfo(nt,:);
        
    else
        
        warning('sample out of limits');
        
    end
    
end