function h_multiple_tfProfileplot(freq,f1,f2)

% input: time-frequency structure + frequency limits 

cfg                     = [];
cfg.frequency           = [f1 f2];

if strcmp(freq.dimord(1:3),'rpt')
    cfg.avgoverrpt          = 'yes';
    fprintf('Averaging over single trials..\n');
end

cfg.avgoverfreq         = 'yes';
freq_slct               = ft_selectdata(cfg,freq);

freq_slct.dimord     = 'chan_time';
freq_slct.avg        = squeeze(freq_slct.powspctrm);
freq_slct            = rmfield(freq_slct,'powspctrm');
freq_slct            = rmfield(freq_slct,'cfg');
freq_slct            = rmfield(freq_slct,'freq');

cfg                 = [];
cfg.layout          = 'CTF275.lay';
ft_multiplotER(cfg,freq_slct);