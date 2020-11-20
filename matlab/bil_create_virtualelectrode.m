clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = [10 20 33] %1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    vox_res                             = '1cm';
    
    fname                               = ['I:/bil/head/' subjectName '.volgridLead.' vox_res '.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                               = [start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                 = [];
    cfg.channel                         = dataPostICA_clean.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    % down-sample
    cfg                                 = [];
    cfg.resamplefs                      = 100;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'yes';
    data                                = ft_resampledata(cfg, dataPostICA_clean); clear dataPostICA_clean
    
    cfg                                 = [];
    cfg.covariance                      = 'yes';
    cfg.covariancewindow                = [-1 6];
    avg                                 = ft_timelockanalysis(cfg,data);
    
    % -- create spatial filter
    cfg                                 = [];
    cfg.method                          = 'lcmv';
    cfg.sourcemodel                     = leadfield;
    cfg.headmodel                       = vol;
    cfg.lcmv.keepfilter                 = 'yes';
    cfg.lcmv.fixedori                   = 'yes';
    cfg.lcmv.projectnoise               = 'yes';
    cfg.lcmv.keepmom                    = 'yes';
    cfg.lcmv.projectmom                 = 'yes';
    cfg.lcmv.lambda                     = '5%' ;
    source                              =  ft_sourceanalysis(cfg, avg);
    spatialfilter                       =  cat(1,source.avg.filter{:});
    
    fname                               = ['I:/bil/source/' subjectName '.wallis.index.mat'];
    fprintf('loading %s\n\n',fname);
    load(fname);
    %     index_vox                           = [index_vox [1:length(index_vox)]'];
    
    data                                = bil_virt_compute(data,index_name,index_vox,spatialfilter,vox_res);
    
    fname_out                           = ['I:/bil/virt/' subjectName '.virtualelectrode.wallis.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'data','-v7.3'); clc;
    
    keep nsuj suj_list start_dir
    
end