function try_qsub_function(sub_name)

fieldtrip_path         = '/home/common/matlab/fieldtrip/';
addpath(fieldtrip_path);
ft_defaults; clear fieldtrip_path;

data_a                  = [];
data_a.time           	= 1:100;
data_a.label          	= {'avg'};
data_a.avg              = rand(1,100);
data_a.dimord           = 'chan_time';

data_b                  = [];
data_b.time           	= 1:100;
data_b.label          	= {'avg'};
data_b.avg              = rand(1,100);
data_b.dimord           = 'chan_time';

cfg                     = [];
cfg.parameter           = 'avg';
cfg.operation           = 'x1-x2';
data_c                  = ft_math(cfg,data_a,data_b);

fname_out               = ['/project/3035002.01/bil/tf/' sub_name '.mat'];
save(fname_out,'data_c');
