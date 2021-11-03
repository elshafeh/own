clear;clc;

dir_data     	= '~/Dropbox/project_me/data/nback/0back/erf/';
fname_in    	= [dir_data 'sub1.0back.erf.mat'];
fprintf('loading %s\n',fname_in);
load(fname_in);

cfg                         = [];
cfg.layout                  = 'neuromag306cmb_helmet.mat';
cfg.xlim                    = 0:0.1:0.5;

cfg.ylim                    = 'maxabs';

cfg.marker                  = 'off';

% cfg.comment                 = 'no';
cfg.colormap                = brewermap(256,'*RdBu');
cfg.colorbar                = 'no';

% cfg.highlight               = 'on';
% cfg.highlightchannel        =  list_channel;
% cfg.highlightsymbol         = 'x';
% cfg.highlightcolor          = [0 1 0];
% cfg.highlightsize           = 8;

% cfg.figure                  = subplot(2,2,1);
ft_topoplotER(cfg, avg_comb);


% 
% erf_left        = avg_comb;
% 
% dir_data     	= '~/Dropbox/project_me/data/nback/0back/erf/';
% fname_in    	= [dir_data 'sub2.0back.erf.mat'];
% fprintf('loading %s\n',fname_in);
% load(fname_in);
% 
% erf_right        = avg_comb;
% 
% lat_index       = (erf_left.avg - erf_right.avg) ./ (erf_left.avg + erf_right.avg);
% 
% avg             = erf_right;
% avg.avg         = lat_index;
% 
% 
% 
