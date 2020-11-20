function spatialfilter = h_create_lcmv_commonFilter_concWindow(data,pkg)

time_list       = pkg.time_of_interest ;
time_window     = pkg.time_window;

for ntime = 1:length(pkg.time_of_interest)
    
    cfg                 = [];
    cfg.latency         = [time_list(ntime) time_list(ntime)+time_window(ntime)];
    poi{ntime}          = ft_selectdata(cfg,data);
    
end

data_filter             = ft_appenddata([],poi{:}); clear data_elan ;

cfg                     = [];
cfg.covariance          = 'yes';
cfg.covariancewindow    = 'all';
avg                     = ft_timelockanalysis(cfg,data_filter);

cfg                     =   [];
cfg.method              =   'lcmv';
cfg.grid                =   pkg.leadfield;
cfg.headmodel           =   pkg.vol;
cfg.lcmv.keepfilter     =   'yes';cfg.lcmv.fixedori       =   'yes';cfg.lcmv.projectnoise   =   'yes';cfg.lcmv.keepmom        =   'yes';cfg.lcmv.projectmom     =   'yes';cfg.lcmv.lambda         =   '15%';
source                  =   ft_sourceanalysis(cfg, avg);

spatialfilter           = source.avg.filter;

time_list               = [time_list time_list+time_window];               

filter_name             = '.lcmvCommonFilter.concatenate_window.Covariance.';

for nt = 1:length(time_list)
    
    if time_list(nt) < 0
        tm_ext      = ['m' num2str(abs(time_list{nt})*1000)];
    else
        tm_ext      = ['p' num2str(abs(time_list{nt})*1000)];
    end
    
    filter_name     = [filter_name tm_ext];
    
end


fname_out           = ['../data/' suj '/field/' pkg.suj '.' pkg.cond_main '.' filter_name 'ms.mat']; clear filter_name ;

fprintf('\n\nSaving %50s \n\n',fname_out); 
save(fname_out,'spatialfilter','-v7.3')