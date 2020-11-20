function newdata = h_eyes_changelock(data)

newdata                             = data;

try
    newdata                         = rmfield(newdata,'sampleinfo');
end
try
    newdata                      	= rmfield(newdata,'cfg');
end

for ntrial = 1:length(data.trialinfo)
    
    time_axis                       = data.time{ntrial};
    new_time_axis                   = time_axis - (-data.trialinfo(ntrial,5));
    
    t                               = find(round(new_time_axis,1) == round(0,1));
    vct                             = abs(new_time_axis(t));
    fnd_min                         = find(vct == min(vct));
    t                               = t(1); clear vct fnd_min;
    
    sec_before                      = 1;
    sec_after                       = 2;
    
    nb_sample_before                = sec_before*data.fsample; % 1 sec 
    nb_sample_after                 = sec_after*data.fsample; % 2 sec
    
    sin_trl_data                    = data.trial{ntrial}(:,t-nb_sample_before:t+nb_sample_after);
    sin_trl_time                    = -sec_before:1/data.fsample:sec_after;
    
    newdata.trial{ntrial}           = sin_trl_data;
    newdata.time{ntrial}            = sin_trl_time;
    
    clear *axis *_trl_*
    
end