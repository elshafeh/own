function freq = in_function_computeTFR(data,fname_in,tf_method,tf_output,tf_trls,tf_wid,tf_gwid,tf_toi,tf_foi,remove_evoked)

if strcmp(remove_evoked,'yes')
    data                    = h_removeEvoked(data);
    name_ext_trials         = 'MinEvoked';
else
    name_ext_trials         = 'eEvoked';
end
    
cfg                         = [];
cfg.method                  = tf_method; %'wavelet';
cfg.output                  = tf_output; %'pow';
cfg.keeptrials              = tf_trls;   %'yes';
cfg.width                   = tf_wid;    %7 ;
cfg.gwidth                  = tf_gwid;   %4 ;
cfg.toi                     = tf_toi;    %-3:0.01:3;
cfg.foi                     = tf_foi;    %freq_list(1):1:freq_list(end)-1;
freq                        = ft_freqanalysis(cfg,data);

% freq                        = h_transform_freq(freq,{1:23,24:42},{'audL','audR'});

freq                        = rmfield(freq,'cfg');

name_ext_tfr                = [cfg.method upper(cfg.output)];
name_ext_time               = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
name_ext_freq               = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];

if strcmp(cfg.keeptrials,'yes')
    name_ext_trials         = [ 'KeepTrials' name_ext_trials];
else
    name_ext_trials         = [ 'AvgTrials' name_ext_trials];
end

fname_out                   = [fname_in '.' name_ext_tfr '.' name_ext_freq '.' name_ext_time '.' name_ext_trials '.mat'];

fprintf('\n\nSaving %50s \n\n',fname_out);
save(fname_out,'freq','-v7.3')