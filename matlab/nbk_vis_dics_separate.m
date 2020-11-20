function [source,ext_name] = nbk_vis_dics_separate(data_in,time_window,leadfield,vol,com_filter)

cfg                             = [];
cfg.toilim                      = time_window;
data                            = ft_redefinetrial(cfg, data_in);

f_focus                         = 4;
freq_tap                        = 2;

cfg                             = [];
cfg.method                      = 'mtmfft';
cfg.foi                         = f_focus;
cfg.tapsmofrq                   = freq_tap;
cfg.output                      = 'powandcsd';
cfg.taper                       = 'dpss';
freq                            = ft_freqanalysis(cfg,data);

ext_freq                        = [num2str(f_focus-freq_tap) 't' num2str(f_focus+freq_tap) 'Hz'];

cfg                             = [];
cfg.method                      = 'dics';
cfg.frequency                   = freq.freq;
cfg.sourcemodel                 = leadfield;
cfg.sourcemodel.filter          = com_filter;
cfg.headmodel                   = vol;
cfg.dics.fixedori               = 'yes';
cfg.dics.projectnoise           = 'yes';
cfg.dics.lambda                 = '5%';
source                          = ft_sourceanalysis(cfg, freq);

tmp                             = [];
tmp.pow                         = source.avg.pow;
tmp.noise                       = source.avg.noise;

source                          = tmp; clear tmp;

if time_window(1) < 0
    ext_ext= 'm';
else
    ext_ext='p';
end

ext_time_source                 = [ext_ext num2str(abs(time_window(1)*1000)) ext_ext num2str(abs((time_window(2))*1000))];

ext_name                        = [ext_freq '.' ext_time_source];