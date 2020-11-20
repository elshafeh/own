clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/data/';
else
    project_dir                     = 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                   	= suj_list{nsuj};
    
    fname                       	= [project_dir subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cfg                             = [];
    cfg.resamplefs                  = 50;
    cfg.detrend                     = 'no';
    cfg.demean                      = 'yes';
    cfg.baselinewindow              = [-0.1 0];
    dataPostICA_clean           	= ft_resampledata(cfg, dataPostICA_clean);
    
    %     cfg                             = [];
    %     cfg.demean                      = 'yes';
    %     cfg.baselinewindow              = [-0.1 0];
    %     cfg.lpfilter                    = 'yes';
    %     cfg.lpfreq                      = 20;
    %     dataPostICA_clean           	= ft_preprocessing(cfg,dataPostICA_clean);
    
    list_cue                    	= {'pre' 'retro' ''};
    
    for ncue = 1:length(list_cue)
        
        if ncue < 3
            cfg                   	= [];
            cfg.trials           	= find(dataPostICA_clean.trialinfo(:,8) == ncue);
            data_axial          	= ft_selectdata(cfg,dataPostICA_clean);
        else
            data_axial           	= dataPostICA_clean;
        end
        
        fname                       = [project_dir subjectName '/tf/' subjectName '.' list_cue{ncue} 'cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
                
        for nbin = 1:length(phase_lock)
            
            cfg                     = [];
            cfg.trials              = phase_lock{nbin}.index; % choose trials
            avg                     = ft_timelockanalysis(cfg, data_axial);
            
            % -- combine planar
            cfg                     = [];
            cfg.feedback            = 'yes';
            cfg.method              = 'template';
            cfg.neighbours          = ft_prepare_neighbours(cfg, avg); close all;
            cfg.planarmethod        = 'sincos';
            avg_planar              = ft_megplanar(cfg, avg);
            avg_comb                = ft_combineplanar([],avg_planar); clear avg avg_planar;clc;
            
            fname                   = [project_dir subjectName '/erf/' subjectName '.' list_cue{ncue} 'cuelock.itc.withcorrect.bin' num2str(nbin) '.erf.mat'];
            fprintf('\nSaving %s\n\n',fname);
            save(fname,'avg_comb','-v7.3'); clear avg_comb;
            
        end
    end
    
end