function data_planar = h_ax2plan(data_axial)

cfg                 = [];
cfg.feedback        = 'no';
cfg.method          = 'template';

if isunix
    if isempty(find(strcmp(data_axial.label,'MRT54')))
        warning('meg system -> NEUROMAG');
        cfg.template   	= '/home/common/matlab/fieldtrip/template/neighbours/neuromag306mag_neighb.mat';
        if ~exist(cfg.template)
            error('template file not found !');
        end
    else
        warning('meg system --> CTF275');
    end
end



cfg.planarmethod    = 'sincos';
cfg.channel         = 'MEG';
cfg.trials          = 'all';
cfg.neighbours      = ft_prepare_neighbours(cfg, data_axial);

data_planar         = ft_megplanar(cfg,data_axial);