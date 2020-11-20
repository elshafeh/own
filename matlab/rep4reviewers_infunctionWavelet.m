function rep4reviewers_infunctionWavelet(data_elan,suj,cond_main)

data_slct               = h_removeEvoked(data_elan);

cfg                     = [];
cfg.output              = 'pow';
cfg.method              = 'wavelet';
cfg.output              = 'pow';
t_step                  = 0.01;
cfg.toi                 = -1:t_step:1;
cfg.foi                 = 10:40;
cfg.width               = 7;
cfg.gwidth              = 3;

cfg.keeptrials          = 'no';

freq                    = ft_freqanalysis(cfg, data_slct);
freq                    = rmfield(freq,'cfg');

name_ext_tfr            = [cfg.method upper(cfg.output)];

name_ext_time           = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000) '.' num2str(t_step*1000) 'Mstep'];
name_ext_freq           = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];

if strcmp(cfg.keeptrials,'yes')
    name_ext_trials = 'KeepTrials';
else
    name_ext_trials = 'AvgTrials';
end

extra_name              = 'MinEvoked';

fname_out               = ['../data/dis_rep4rev/' suj '.' cond_main '.' name_ext_tfr '.' name_ext_freq '.' name_ext_time '.' name_ext_trials '.' extra_name '.mat'];

fprintf('Saving %s\n\n',fname_out);

save(fname_out,'freq','-v7.3');

clear freq data_slct