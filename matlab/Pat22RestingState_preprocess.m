clear ;

addpath('/Users/heshamelshafei/Documents/GitHub/fieldtrip/');
ft_defaults;

ds_name                         = '/Volumes/HESHAM_DOWN/resting_state/magni_CAT_20170306_11.ds';

cfg                             = [];
cfg.dataset                     = ds_name;
cfg.continuous                  = 'yes';
cfg.channel                     = 'MEG';
InitRej                         = ft_preprocessing(cfg);

% cfg                             = [];
% cfg.method                      = 'summary';
% cfg.megscale                    = 1;
% InitRej                         = ft_rejectvisual(cfg,data_orig);
% cfg                             = [];
% SecondRej                       = ft_databrowser(cfg,InitRej);

cfg                             = [];
cfg.method                      = 'runica';
comp                            = ft_componentanalysis(cfg,InitRej);

cfg                             = [];
cfg.component                   = 1:40;
cfg.comment                     = 'no';
cfg.markers                     = 'off';
cfg.layout                      = 'CTF275.lay';
ft_topoplotIC(cfg,comp);clc;

% 19 20 27 33

cfg                             = [];
cfg.layout                      = 'CTF275.lay';
cfg.viewmode                    = 'component';
ft_databrowser(cfg,comp);

cfg                             = [];
cfg.component                   = [27 20];
cfg.demean                      = 'no';
dataPostICA                     = ft_rejectcomponent(cfg,comp,InitRej);