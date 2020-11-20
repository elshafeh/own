function h_dicsCommonFilter(suj,data_in,pkg,n_prt,list_time,f_focus,tap,formul,ext_filt)

cfg               = [];
cfg.method        = 'mtmfft';
cfg.foi           = f_focus;
cfg.tapsmofrq     = tap;
cfg.output        = 'powandcsd';
cfg.trials        = 1;
freq              = ft_freqanalysis(cfg,data_in); clc ;

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = pkg.leadfield;
cfg.headmodel           = pkg.vol;
cfg.dics.keepfilter     = 'yes';
cfg.dics.fixedori       = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
source                  = ft_sourceanalysis(cfg, freq);

com_filter              = source.avg.filter;

ext_time = ['m' num2str(abs(list_time(1))*1000) 'p' num2str((list_time(2))*1000)];
ext_freq  = [num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz'];

FnameFilterOut = [suj '.pt' num2str(n_prt) '.' ext_filt '.' ext_freq '.' ext_time '.FixedCommonFilter' ];
fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
save(['../data/filter/' FnameFilterOut '.mat'],'com_filter','-v7.3');