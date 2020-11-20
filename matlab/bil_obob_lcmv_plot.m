clear ; close all;

if isunix
    project_dir                         = '/project/3015079.01/';
    addpath('/home/mrphys/hesels/github/obob_ownft/');
else
    project_dir                         = 'P:/3015079.01/';
end

obob_init_ft;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    fname                               = ['/project/3015039.06/bil/virtual/' subjectName '.obob333.dwn70.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);data                 	= data_virt; clear data_virt;
    
    alldata{nsuj}                       = ft_timelockanalysis([],data);
    alldata{nsuj}.avg                	= abs(alldata{nsuj}.avg);

    
end

keep alldata;

load('../data/stock/obob_parcellation_grid_5mm.mat');

gavg                                    = ft_timelockgrandaverage([],alldata{:});

cfg                                     = [];
cfg.baseline                            = [-0.1 0];
gavg                                    = ft_timelockbaseline(cfg,gavg);
gavg.avg                                = abs(gavg.avg);

cfg                                     = [];
cfg.layout                            	= parcellation.layout;
ft_topoplotER(cfg,gavg);