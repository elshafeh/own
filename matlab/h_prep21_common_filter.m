function com_filter = h_prep21_common_filter(data_elan,leadfield,vol,name_in,name_extra,taper_type,foi,fwindow,toi_lim)

cfg                     = [];
cfg.toilim              = toi_lim;
poi                     = ft_redefinetrial(cfg, data_elan);

ext_time                = ['m' num2str(abs(cfg.toilim(1))*1000) 'p' num2str((cfg.toilim(2))*1000)];

cfg                     = [];
cfg.method              = 'mtmfft';
cfg.output              = 'fourier';
cfg.keeptrials          = 'yes';
cfg.taper               = taper_type;
%-----%
cfg.foi                 = foi;
cfg.tapsmofrq           = fwindow;
%-----%

freqCommon              = ft_freqanalysis(cfg,poi);

ext_freq                = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];

cfg                     = [];
cfg.frequency           = freqCommon.freq;
cfg.method              = 'pcc';
cfg.grid                = leadfield;
cfg.headmodel           = vol;
cfg.keeptrials          = 'yes';
cfg.pcc.lambda          = '5%';
cfg.pcc.projectnoise    = 'yes';
cfg.pcc.keepfilter      = 'yes';
cfg.pcc.fixedori        = 'yes';
source                  = ft_sourceanalysis(cfg, freqCommon);
com_filter              = source.avg.filter;

FnameFilterOut  = [name_in '.' ext_freq '.' ext_time '.PCCommonFilter' name_extra '0.5cm.mat'];

fprintf('\n\nSaving %50s \n\n',FnameFilterOut);