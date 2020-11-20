clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir                             = '/project/3015079.01/';
    start_dir                               = '/project/';
else
    project_dir                             = 'P:/3015079.01/';
    start_dir                               = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    subject_folder                          = [project_dir 'data/' subjectName '/preproc/'];
    
    fname                                   = [subject_folder subjectName '.1stcue.lock.broadband.centered.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_band                               = {'theta' 'alpha' 'beta'};
    list_window                             = {'preCue1' 'preGab1' 'preCue2' 'preGab2'};
    
    for nband = 1:length(list_band)
        for nwin = 1:length(list_window)
            
            chk                             = dir([project_dir 'data/' subjectName '\tf\' subjectName '.allbandbinning.' list_band{nband} '.band.' list_window{nwin} '.window.index.mat']);
            
            if length(chk) == 1
                fname                       = [chk(1).folder filesep chk(1).name];
                fprintf('loading %s\n',fname);
                load(fname);
                
                for nbin = [1 5]
                    
                    cfg                     = [];
                    cfg.trials              = bin_index(:,nbin);
                    data_slct               = ft_selectdata(cfg,data);
                    
                    cfg                     = [];
                    cfg.preproc.demean      = 'yes';    % enable demean to remove mean value from each single trial
                    cfg.covariance          = 'yes';    % calculate covariance matrix of the data
                    cfg.covariancewindow    = [-0.1 0]; % calculate the covariance matrix for a specific time window
                    data_avg                = ft_timelockanalysis(cfg, data_slct);
                    
                    cfg                     = [];
                    cfg.method              = 'amplitude';
                    data_gfp                = ft_globalmeanfield(cfg,data_avg);
                    
                    data_gfp                = rmfield(data_gfp,'cfg'); clear data_avg data_slct
                    
                    fname_out           	= [project_dir 'data/' subjectName '\erf\' subjectName '.binning.' list_band{nband} '.band.' list_window{nwin} '.window'];
                    fname_out           	= [fname_out '.bin' num2str(nbin) '.gfp.mat'];
                    fprintf('Saving %s\n',fname_out);
                    tic;save(fname_out,'data_gfp','-v7.3');toc; clear data_gfp fname_out;
                    
                end
            end
        end
    end
end