clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj                                             = 'yc1';

vox_size                                        = 0.5;
cond_main                                       = {'DIS'};

dir_data                                        =['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];

load([dir_data suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
load([dir_data suj '.VolGrid.' num2str(vox_size) 'cm.mat']);

fname_in                                        = [dir_data suj '.' cond_main{:} '.mat'];
fprintf('Loading %s\n',fname_in);
load(fname_in)

data_concat                                     = data_elan; clear data_elan;

list_extra.name                                 = {'MinEvokedGamma'};
list_extra.filt.toi                             = [-0.2 0.4];
list_extra.filt.foi                             = [80 30];
list_extra.wind.toi                             = [0.1 0.2];
list_extra.wind.foi                             = [80 20];
    
taper_type                                      = 'dpss';
n_ex                                            = 1;

cfg                                             = [];
cfg.toilim                                      = list_extra.filt.toi(n_ex,:);
poiCommon                                       = ft_redefinetrial(cfg, data_concat);

cfg                                             = [];
cfg.method                                      = 'mtmfft';
cfg.output                                      = 'fourier';
cfg.keeptrials                                  = 'yes';
cfg.taper                                       = taper_type;
cfg.foi                                         = list_extra.filt.foi(n_ex,1);
cfg.tapsmofrq                                   = list_extra.filt.foi(n_ex,2);
freqCommon                                      = ft_freqanalysis(cfg,poiCommon);

cfg                                             = [];
cfg.frequency                                   = freqCommon.freq;
cfg.method                                      = 'pcc';
cfg.grid                                        = leadfield;
cfg.headmodel                                   = vol;
cfg.keeptrials                                  = 'yes';
cfg.pcc.lambda                                  = '5%';
cfg.pcc.projectnoise                            = 'yes';
cfg.pcc.keepfilter                              = 'yes';
cfg.pcc.fixedori                                = 'yes';
source                                          = ft_sourceanalysis(cfg, freqCommon);