function com_filter= h_dicsCommonFilter(suj,data_in,pkg,list_time,f_focus,h_tap,ext_filt_1,ext_filt2,reg_lambda,taper_type)

% suj : name of subject 
% data_in : raw data to be entered
% pkg : structure with leadfield and volume
% list_time : period of interest
% f_focus : center frequency
% h_tap : width of frequency window ; output will be [f_focus-h_tap f_focus
% + h_tap] 
% ext_filt_1 : customise the name of your filter :) 
% ext_filt2 : customise the name of your filter  :) 

cfg                     = [];
cfg.toilim              = list_time;
data_in                 = ft_redefinetrial(cfg, data_in);

cfg                     = [];
cfg.method              = 'mtmfft';
cfg.foi                 = f_focus;
cfg.tapsmofrq           = h_tap;
cfg.output              = 'powandcsd';
cfg.taper               = taper_type;
freq                    = ft_freqanalysis(cfg,data_in); clc ;

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = pkg.leadfield;
cfg.headmodel           = pkg.vol;
cfg.dics.keepfilter     = 'yes';
cfg.dics.fixedori       = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = reg_lambda ; % '5%';
source                  = ft_sourceanalysis(cfg, freq);

com_filter              = source.avg.filter;

ext_time                = ['m' num2str(abs(list_time(1))*1000) 'p' num2str((list_time(2))*1000)];
ext_freq                = [num2str(f_focus-h_tap) 't' num2str(f_focus+h_tap) 'Hz'];

FnameFilterOut          = [suj '.' ext_filt_1 '.' ext_freq '.' ext_time '.' ext_filt2];

fprintf('\n\nSaving %50s \n\n',FnameFilterOut);