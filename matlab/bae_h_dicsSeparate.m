function source = h_dicsSeparate(suj,data_in,tpoint,twin,tpad,f_focus,freq_tap,com_filter,pkg,ext_source_1,ext_source_2)

%suj ; name of subject 
%data_in ;raw data to be entered
%tpoint ; beginning of your time-window of interest
%twin ; size of your time window
%tpad ; value that can be used to modify the frequency-resolution that can
%be obtained in your time window
%f_focus ; center frequency
%freq_tap ; width of frequency window ; output will be [f_focus-h_tap f_focus
% + h_tap]
%com_filter ; common filter 
%pkg ; structure with leadfield and volume
%ext_source_1 ; customise the name of your source ;) 
%ext_source_2 ; customise the name of your source ;) 

cfg                     = [];
cfg.toilim              = [tpoint-tpad tpoint+tpad+twin];
data                    = ft_redefinetrial(cfg, data_in);

cfg                     = [];
cfg.method              = 'mtmfft';
cfg.foi                 = f_focus;
cfg.tapsmofrq           = freq_tap;
cfg.output              = 'powandcsd';
freq                    = ft_freqanalysis(cfg,data);

ext_freq                = [num2str(f_focus-freq_tap) 't' num2str(f_focus+freq_tap) 'Hz'];

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = pkg.leadfield;
cfg.grid.filter         = com_filter ;
cfg.headmodel           = pkg.vol;
cfg.dics.fixedori       = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
source                  = ft_sourceanalysis(cfg, freq);
source                  = source.avg.pow;

if tpoint < 0
    ext_ext= 'm';
else
    ext_ext='p';
end

ext_time_source         = [ext_ext num2str(abs(tpoint*1000)) ext_ext num2str(abs((tpoint+twin)*1000))];
f_name_source           = [suj '.' ext_source_1 '.' ext_freq '.' ext_time_source '.' ext_source_2];

fprintf('\n\nSaving %50s \n\n',f_name_source);
% save(['../data/' suj '/field/' f_name_source '.mat'],'source','-v7.3');
