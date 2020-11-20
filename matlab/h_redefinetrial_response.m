function [new_data,keep_trial] = h_redefinetrial_response(cfg,data)

new_data                            = data;

new_data.trial                      = {};
new_data.time                       = {};
new_data.trialinfo                  = [];

icount                              = 0;

for nt = 1:length(data.trial)
    
    find_zero                       = find(round(data.time{nt},4) == round(0,4));
    
    if isempty(find_zero)
        find_zero                	= find(round(data.time{nt},3) == round(0,3));
    end
    
    if isempty(find_zero)
        find_zero                	= find(round(data.time{nt},2) == round(0,2));
    end
    
    find_zero                       = find_zero(1);
    
    ix_start                        = (find_zero+cfg.begsample(nt)) - cfg.window(1)*data.fsample;
    ix_end                          = (find_zero+cfg.begsample(nt)) + cfg.window(2)*data.fsample;
    
    if (ix_start <= length(data.trial{nt})) && (ix_start > 0)
        if (ix_end <= length(data.trial{nt})) && (ix_end > 0)
            
            icount                  = icount + 1;
            
            sin_trl                 = data.trial{nt}(:,ix_start:ix_end);
            sin_time                = -cfg.window(1):1/data.fsample:cfg.window(2);
            
            new_data.trial{icount}  = sin_trl;
            new_data.time{icount}   = sin_time;
            
            new_data.trialinfo      = [new_data.trialinfo;data.trialinfo(nt,:)];
            
            keep_trial(icount)      = nt;
            
        end
    end
    
end

new_data                         	= rmfield(new_data,'sampleinfo');

fprintf('%2d trials discarded\n',length(data.trial) - length(new_data.trial));