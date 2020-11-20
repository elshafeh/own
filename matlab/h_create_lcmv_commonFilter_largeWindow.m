function spatialfilter = h_create_lcmv_commonFilter_largeWindow(data,pkg)

cfg                     = [];
cfg.latency             = pkg.covariance_window;
data_select             = ft_selectdata(cfg,data);

cfg                     = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = pkg.covariance_window;
avg                     = ft_timelockanalysis(cfg,data_select);

cfg                     =   [];
cfg.method              =   'lcmv';
cfg.grid                =   pkg.leadfield;
cfg.headmodel           =   pkg.vol;
cfg.lcmv.keepfilter     =   'yes';cfg.lcmv.fixedori       =   'yes';cfg.lcmv.projectnoise   =   'yes';cfg.lcmv.keepmom        =   'yes';cfg.lcmv.projectmom     =   'yes';cfg.lcmv.lambda         =   '15%';
source                  =   ft_sourceanalysis(cfg, avg);

spatialfilter           = source.avg.filter;

tm_pnt{1}               = pkg.covariance_window(1);
tm_pnt{2}               = pkg.covariance_window(2);

for nt = 1:length(tm_pnt)
    if tm_pnt{nt} < 0
        tm_ext{nt} = ['m' num2str(abs(tm_pnt{nt})*1000)];
    else
        tm_ext{nt} = ['p' num2str(abs(tm_pnt{nt})*1000)];
    end
end

filter_name         = ['.lcmvCommonFilter.large_window.Covariance.' tm_ext{1} tm_ext{2} 'ms'];

fname_out           = ['../data/' suj '/field/' pkg.suj '.' pkg.cond_main '.' filter_name '.mat']; clear filter_name ;

fprintf('\n\nSaving %50s \n\n',fname_out); 
save(fname_out,'spatialfilter','-v7.3')
