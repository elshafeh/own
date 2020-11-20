[file,path]                                 = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        subjectName                         = list_suj{ns};
        modality                            = list_modality{nm};
        
        chk                                 = dir(['../data/' subjectName '/mri/' subjectName '_segmentMRI.mat']);
        
        if ~isempty(chk)
            
            dir_data                        = ['../data/' subjectName '/mri/'];
            
            fname                           = [dir_data subjectName '_' modality '_leadfield.mat'];
            fprintf('loading %s \n',fname);
            load(fname);
            
            fname                       = [dir_data subjectName '_gridVol.mat'];
            fprintf('loading %s \n',fname);
            load(fname);
            
            fname                       = ['../data/' subjectName '/preprocessed/' subjectName '_secondreject_postica_' modality '.mat'];
            fprintf('loading %s \n',fname);
            load(fname);
            
            cfg                         = [];
            cfg.lpfilter                = 'yes';
            cfg.lpfreq                  = 30;
            data_preproc                = ft_preprocessing(cfg,secondreject_postica);
            
            clear secondreject_postica
            
            cfg                         = [];
            cfg.latency                 = [-1 1];
            data_select                 = ft_selectdata(cfg,data_preproc);
            
            cfg                         = [];
            cfg.covariance              = 'yes';
            cfg.covariancewindow        = [-1 1];
            avg                         = ft_timelockanalysis(cfg,data_select);
            
            cfg                         = [];
            cfg.method                  = 'lcmv';
            cfg.grid                    = leadfield;
            cfg.headmodel               = vol;
            cfg.lcmv.keepfilter         = 'yes';
            cfg.lcmv.fixedori           = 'yes';
            cfg.lcmv.projectnoise       = 'yes';
            cfg.lcmv.keepmom            = 'yes';
            cfg.lcmv.projectmom         = 'yes';
            cfg.lcmv.lambda             = '5%';
            source                      = ft_sourceanalysis(cfg, avg);
            spatialfilter               = source.avg.filter;
            
            list_time                   = [-0.1 0; 0 0.1; 0.1 0.2; 0.2 0.3; 0.3 0.4; 0.4 0.5];
            
            for nt = 1:size(list_time,1)
                
                cfg                     = [];
                cfg.toilim              = list_time(nt,:);
                data_select             = ft_redefinetrial(cfg, data_preproc);
                
                cfg                     = [];
                cfg.covariance          = 'yes';
                cfg.covariancewindow    = 'all';
                avg                     = ft_timelockanalysis(cfg,data_select);
                
                cfg                     =   [];
                cfg.method              =   'lcmv';
                cfg.grid                =   leadfield;
                cfg.grid.filter         =   spatialfilter;
                cfg.headmodel           =   vol;
                cfg.lcmv.fixedori       =   'yes';
                cfg.lcmv.projectnoise   =   'yes';
                cfg.lcmv.keepmom        =   'yes';
                cfg.lcmv.projectmom     =   'yes';
                cfg.lcmv.lambda         =   '5%';
                source                  =   ft_sourceanalysis(cfg, avg);
                
                source                  = rmfield(source,'cfg');
                
                dir_out                 = ['../data/' subjectName '/source/'];
                mkdir(dir_out);
                
                fname                   = [dir_out subjectName '.lcmvsource.' modality '.' num2str(nt) '.mat'];
                fprintf('saving %s \n',fname);
                save(fname,'source','-v7.3');
                
                clear avg data_select soource
                
            end
        end
    end
end