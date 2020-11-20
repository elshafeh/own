function [spatialfilter,filter_name] = h_create_lcmv_commonFilter(data,pkg,cov_array)

cfg                     = [];
cfg.latency             = cov_array;
data                    = ft_selectdata(cfg,data);

cfg                     = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = cov_array;
avg                     = ft_timelockanalysis(cfg,data);

cfg                     =   [];
cfg.method              =   'lcmv';
cfg.grid                =   pkg.leadfield;
cfg.headmodel           =   pkg.vol;
cfg.lcmv.keepfilter     =   'yes';
cfg.lcmv.fixedori       =   'yes';
cfg.lcmv.projectnoise   =   'yes';
cfg.lcmv.keepmom        =   'yes';
cfg.lcmv.projectmom     =   'yes';
cfg.lcmv.lambda         =   '15%';
source                  =   ft_sourceanalysis(cfg, avg);

spatialfilter           = source.avg.filter;

tm_pnt{1}               = cov_array(1);
tm_pnt{2}               = cov_array(2);

for nt = 1:length(tm_pnt)
    if tm_pnt{nt} < 0
        tm_ext{nt} = ['m' num2str(abs(tm_pnt{nt})*1000)];
    else
        tm_ext{nt} = ['p' num2str(abs(tm_pnt{nt})*1000)];
    end
end

filter_name         = ['Covariance.' tm_ext{1} tm_ext{2} 'ms.lcmvCommonFilter'];