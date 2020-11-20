function [source,source_name] = h_lcmv_separate(data_slct,pkg)

for ntime = 1:length(pkg.time_of_interest)
    
    win_slct                = [pkg.time_of_interest(ntime) pkg.time_of_interest(ntime)+pkg.time_window(ntime)];
    
    cfg                     = [];
    cfg.toilim              = win_slct;
    nw_data                 = ft_redefinetrial(cfg,data_slct);
    
    cfg                     = [];
    cfg.covariance          = 'yes';
    cfg.covariancewindow    = 'all';
    avg                     = ft_timelockanalysis(cfg,nw_data);
    
    cfg                     =   [];
    cfg.method              =   'lcmv';
    cfg.grid                =   pkg.leadfield;
    cfg.grid.filter         =   pkg.spatialfilter;
    cfg.headmodel           =   pkg.vol;
    cfg.lcmv.fixedori       =   'yes';
    cfg.lcmv.projectnoise   =   'yes';
    cfg.lcmv.keepmom        =   'yes';
    cfg.lcmv.projectmom     =   'yes';
    cfg.lcmv.lambda         =   pkg.lambda;
    source                  =   ft_sourceanalysis(cfg, avg);
    
    source                  = source.avg.pow;
    
    tm_pnt{1}               = win_slct(1);
    tm_pnt{2}               = win_slct(2);
    
    for nt = 1:length(tm_pnt)
        if tm_pnt{nt} < 0
            tm_ext{nt} = ['m' num2str(abs(tm_pnt{nt})*1000)];
        else
            tm_ext{nt} = ['p' num2str(abs(tm_pnt{nt})*1000)];
        end
    end
    
    source_name         = [tm_ext{1} tm_ext{2} 'ms.lcmvSource' pkg.lambda];
    
    
    fname_out           = [pkg.ext_name '.' source_name '.mat'];
    
    fprintf('\n\nSaving %50s \n\n',fname_out);
    
    save(fname_out,'source','-v7.3');
    
end