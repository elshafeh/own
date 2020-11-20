function freq = in_function_computeTFR_special(data,fname_in,tf_method,tf_output,tf_trls,tf_wid,tf_gwid,tf_toi,tf_foi,remove_evoked)

if strcmp(remove_evoked,'yes')
    data                = h_removeEvoked(data);
    name_ext_trials     = 'MinEvoked';
else
    name_ext_trials     = 'eEvoked';
end
    
cfg                         = [];
cfg.method                  = tf_method;%'wavelet';
cfg.output                  = tf_output;%'pow';
cfg.keeptrials              = tf_trls;%'yes';
cfg.width                   = tf_wid;%7 ;
cfg.gwidth                  = tf_gwid;%4 ;
cfg.toi                     = tf_toi;%-3:0.01:3;
cfg.foi                     = tf_foi;%freq_list(1):1:freq_list(end)-1;
freq                        = ft_freqanalysis(cfg,data);
freq                        = rmfield(freq,'cfg');

name_ext_tfr                = [cfg.method upper(cfg.output)];
name_ext_time               = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
name_ext_freq               = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];

if strcmp(cfg.keeptrials,'yes')
    name_ext_trials = [name_ext_trials 'KeepTrials'];
else
    name_ext_trials = [name_ext_trials 'AvgTrials'];
end

load ../data_fieldtrip/index/broad_vis_aud_motor.mat

where_visl                  = find(index_H(:,2)==1);
where_visr                  = find(index_H(:,2)==2);
where_audl                  = find(index_H(:,2)==3);
where_audr                  = find(index_H(:,2)==4);
where_motl                  = find(index_H(:,2)==5);
where_motr                  = find(index_H(:,2)==6);

freq                        = h_transform_freq(freq,{where_visl,where_visr,where_audl,where_audr,where_motl,where_motr},list_H);

fname_out                   = [fname_in '.' name_ext_tfr '.' name_ext_freq '.' name_ext_time '.' name_ext_trials '.mat'];

fprintf('\n\nSaving %50s \n\n',fname_out);
save(fname_out,'freq','-v7.3');