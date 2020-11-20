clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    
    fname                               = ['I:/hesham/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                               = [start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                 = [];
    cfg.channel                         = dataPostICA_clean.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    % -- sub-select correct trials
    cfg                                 = [];
    cfg.trials                          = find(dataPostICA_clean.trialinfo(:,16) == 1);
    dataPostICA_clean                   = ft_selectdata(cfg,dataPostICA_clean);
    
    % -- select time-window for spatial filter
    cfg                                 = [];
    cfg.toilim                          = [3 7];
    data_4_filter                       = ft_redefinetrial(cfg,dataPostICA_clean);
    
    cfg                                 = [];
    cfg.covariance                      = 'yes';
    filter_avg                          = ft_timelockanalysis(cfg, data_4_filter); clear data_4_filter;
    
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
    source                              =  ft_sourceanalysis(cfg, filter_avg);
    spatialfilter                       =  cat(1,source.avg.filter{:});
    
    flist                               = dir(['I:/bil/decode/' subjectName '.*.decodingresp.*.coef.mat']);
    
    for nfile = 1:length(flist)
        
        ext_name                        = flist(nfile).name(1:end-4);
        fname                           = [flist(nfile).folder filesep flist(nfile).name];
        fprintf('loading %s\n',fname);
        load(fname);
        
        data                            = [];
        data.avg                        = [coef]' * [spatialfilter]';
        data.avg                        = data.avg';
        data.dimord                     = 'chan_time';
        data.label                      = cellstr(num2str([1:size(spatialfilter,1)]'));
        data.time                       = time_axis;
        
        fname_out                       = ['I:/bil/coef/' ext_name '.lcmv.mat'];
        fprintf('saving %50s\n',fname_out);
        save(fname_out,'data'); clear data fname_out ext_name fname;
        
    end
end