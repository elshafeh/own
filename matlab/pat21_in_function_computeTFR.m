function in_function_computeTFR(data,fname_in)

cfg                         = [];
cfg.method                  = 'wavelet';
cfg.output                  = 'pow';
cfg.keeptrials              = 'no';
cfg.width                   =  7 ;
cfg.gwidth                  =  4 ;
cfg.toi                     = -3:0.01:3;
cfg.foi                     = [4:1:20 22:2:140];
freq                        = ft_freqanalysis(cfg,data);
freq                        = rmfield(freq,'cfg');

if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;

ext_time                    = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
ext_freq                    = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];

fname_out = ['../data/tfr/' fname_in '.' ext_trials '.' ext_method upper(cfg.output) '.' ext_freq '.' ext_time '.mat'];

fprintf('\n\nSaving %50s \n\n',fname_out);
save(fname_out,'freq','-v7.3')
