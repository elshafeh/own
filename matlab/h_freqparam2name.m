function ext_freq = h_freqparam2name(cfg)
 
name_ext_tfr        = [cfg.method upper(cfg.output)];
 
cfg.toi(1)          = round(cfg.toi(1),1);% *1000;
cfg.toi(end)        = round(cfg.toi(end),1);%*1000;
 
ix1                 = cfg.toi(1);
ix2                 = cfg.toi(end);
 
if ix1 < 0
    name_ext_time1       = ['m' num2str(abs(cfg.toi(1)))];
else
    name_ext_time1       = ['p' num2str(abs(cfg.toi(1)))];
end
 
if ix2 < 0
    name_ext_time2       = ['m' num2str(abs(cfg.toi(end))) 's'];
else
    name_ext_time2       = ['p' num2str(abs(cfg.toi(end))) 's'];
end
 
name_ext_time       = [name_ext_tfr '.' name_ext_time1 name_ext_time2]; clear name_ext_time1 name_ext_time2;
 
name_ext_freq       = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];
name_freq_step      = [num2str(cfg.foi(2)-cfg.foi(1)) 'HzStep'];
name_time_step      = [num2str((cfg.toi(3)-cfg.toi(2)) * 1000) 'msStep'];
 
if strcmp(cfg.keeptrials,'yes')
    name_ext_trials = 'KeepTrials';
else
    name_ext_trials = 'AvgTrials';
end
 
ext_freq            = [name_ext_time '.' name_time_step '.' name_ext_freq '.' name_freq_step '.' name_ext_trials];
% ext_freq            = [name_ext_freq '.' name_freq_step '.' name_ext_trials];
keep ext_freq
