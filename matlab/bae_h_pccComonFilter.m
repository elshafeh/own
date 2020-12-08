function com_filter     = h_pccComonFilter(suj,data_in,pkg,list_time,f_focus,h_tap,ext_filt_1,ext_filt2)

cfg                     = [];
cfg.toilim              = list_time;
data_in                 = ft_redefinetrial(cfg, data_in);

cfg                     = [];
cfg.method              = 'mtmfft';
cfg.output              = 'fourier';
cfg.keeptrials          = 'yes';
cfg.foi                 = f_focus;
cfg.tapsmofrq           = h_tap;

freq                    = ft_freqanalysis(cfg,data_in); clc ;

cfg                     = [];
cfg.method              = 'pcc';
cfg.frequency           = freq.freq;
cfg.grid                = pkg.leadfield;
cfg.headmodel           = pkg.vol;
cfg.pcc.lambda          = '5%';
cfg.pcc.keepfilter      = 'yes';
cfg.pcc.projectnoise    = 'yes';
cfg.pcc.fixedori        = 'yes';
cfg.keeptrials          = 'yes';
source                  = ft_sourceanalysis(cfg, freq);
com_filter              = source.avg.filter;

ext_time                = ['m' num2str(abs(list_time(1))*1000) 'p' num2str((list_time(2))*1000)];
ext_freq                = [num2str(f_focus-h_tap) 't' num2str(f_focus+h_tap) 'Hz'];

FnameFilterOut = [suj '.' ext_filt_1 '.' ext_freq '.' ext_time '.' ext_filt2];

fprintf('\n\nSaving %50s \n\n',FnameFilterOut);

save(['../data/' suj '/field/' FnameFilterOut '.mat'],'com_filter','-v7.3');