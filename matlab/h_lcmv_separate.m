function [source,source_name] = h_lcmv_separate(cfg_in,data_in)

cfg                         = [];
cfg.latency               	= cfg_in.time_of_interest;
nw_data                     = ft_selectdata(cfg,data_in);

cfg                         = [];
cfg.covariance              = 'yes';
cfg.covariancewindow        = 'all';
avg                         = ft_timelockanalysis(cfg,nw_data);

cfg                         = [];
cfg.method                  = 'lcmv';
cfg.sourcemodel             = cfg_in.leadfield;
cfg.headmodel               = cfg_in.vol;
% cfg.lcmv.keepfilter         = 'yes';
% cfg.lcmv.fixedori           = 'yes';
cfg.lcmv.projectnoise       = 'yes';
cfg.lcmv.keepmom            = 'yes';
cfg.lcmv.projectmom         = 'yes';
cfg.lcmv.lambda             = '5%' ;
cfg.sourcemodel.filter    	= cfg_in.spatialfilter;
source                      =  ft_sourceanalysis(cfg, avg);

source                      = source.avg.pow;

tm_pnt{1}                   = cfg_in.time_of_interest(1);
tm_pnt{2}                   = cfg_in.time_of_interest(2);

for nt = 1:length(tm_pnt)
    if tm_pnt{nt} <= 0
        tm_ext{nt}          = ['m' num2str(abs(tm_pnt{nt})*1000)];
    else
        tm_ext{nt}          = ['p' num2str(abs(tm_pnt{nt})*1000)];
    end
end

source_name                 = [tm_ext{1} tm_ext{2} 'ms'];