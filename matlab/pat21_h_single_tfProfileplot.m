function h_single_tfProfileplot(freq,f1,f2,chn_list)

% input: time-frequency structure + frequency limits and channels needed to
% be averaged

cfg                     = [];
cfg.frequency           = [f1 f2];
cfg.channel             = chn_list;

if strcmp(freq.dimord(1:3),'rpt')
    cfg.avgoverrpt          = 'yes';
    fprintf('Averaging over single trials..\n');
end

cfg.avgoverchan         = 'yes';
cfg.avgoverfreq         = 'yes';
freq_slct               = ft_selectdata(cfg,freq);

freq_slct.dimord     = 'chan_time';
freq_slct.avg        = squeeze(freq_slct.powspctrm)';
freq_slct            = rmfield(freq_slct,'powspctrm');
freq_slct            = rmfield(freq_slct,'cfg');
freq_slct            = rmfield(freq_slct,'freq');

cfg                 = [];
ft_singleplotER(cfg,freq_slct);