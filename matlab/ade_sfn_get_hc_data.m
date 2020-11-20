clear ;

[file,path]                                             = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

for nm = 1:length(list_modality)
    
    list_suj                                            = goodsubjects{nm};
    
    trigger_val(1,:)                                    = [101,102,103,104,111,112,113,114];
    trigger_val(2,:)                                    = [201,202,203,204,211,212,213,214];
    
    for ns = 1:length(list_suj)
        
        suj                                             = list_suj{ns};
        modality                                        = list_modality{nm};
        
        fname                                           = ['../data/' suj '/preprocessed/' suj '_hc_data_' modality '.mat'];
        
        if ~exist(fname)
            
            dir_data                                        = ['/project/3015039.04/raw/sub-0' suj(5:end) '/ses-meg' modality '/meg/'] ;
            ds_name                                         = dir(fullfile(dir_data,'*.ds'));
            
            raw_input                                       = {};
            raw_input{1}                                    = ds_name.folder;
            raw_input{2}                                    = ds_name.name;
            raw_input                                       = strjoin(raw_input,'/');
            
            % define trials
            cfg                                             = [];
            cfg.dataset                                     = raw_input ;
            cfg.trialdef.eventvalue                         = trigger_val(nm,:);       % locking trial based on targets- trigger coding scheme
            cfg.trialdef.eventtype                          = 'UPPT001';                 % frontpanel and uppt001 send same trigger codes
            cfg.trialfun                                    = 'ft_trialfun_general' ;
            cfg.trialdef.prestim                            = 3 ;
            cfg.trialdef.poststim                           = 3 ;
            cfg.continuous                                  = 'yes';
            fprintf('Defining trials %s \n',suj);
            cfg                                             = ft_definetrial(cfg);
            
            % Exception Section
            if strcmp(suj,'sub006') && strcmp(suj,'vis')
                new_trl                                     = cfg.trl(1:192,:);
                new_trl(193:864,:)                          = cfg.trl(273:944,:);
                cfg.trl                                     = [] ; cfg.trl = new_trl ;
            end
            
            if strcmp(suj,'sub006') && strcmp(modality,'vis')
                new_trl                                     = cfg.trl(1:192,:);
                new_trl(193:864,:)                          = cfg.trl(273:944,:);
                cfg.trl                                     = [] ; cfg.trl = new_trl ;
            end
            
            if strcmp(suj,'sub007') && strcmp(modality,'aud')
                new_trl                                     = cfg.trl(1:576,:);
                new_trl(577:864,:)                          = cfg.trl(716:1003,:);
                cfg.trl                                     = [] ; cfg.trl  = new_trl ;
            end
            
            if strcmp(suj,'sub008') && strcmp(modality,'aud')
                new_trl                                     = cfg.trl(1:384,:);
                cfg.trl                                     = [] ; cfg.trl = new_trl ;
            end
            
            if strcmp(suj,'sub012') && strcmp(modality,'aud')
                new_trl                                     = cfg.trl ;
                new_trl(481:484,:)                          = [];
                cfg.trl                                     = new_trl;
            end
            
            if strcmp(suj,'sub013') && strcmp(modality,'aud')
                new_trl                                     = cfg.trl ;
                new_trl(1:96,:)                             = [];
                cfg.trl                                     = new_trl;
            end
            
            cfg                                             = h_log2trl(cfg,suj,modality);  % logfile information into cfg.trl
            
            fname                                           = ['../data/' suj '/preprocessed/' suj '_secondreject_postica_' modality '.trialinfo.mat'];
            load(fname);
            
            cfg.trl                                         = cfg.trl(trialinfo(:,1),:);
            
            cfg.channel                                     = {'HLC0011','HLC0012','HLC0013', ...
                'HLC0021','HLC0022','HLC0023', ...
                'HLC0031','HLC0032','HLC0033'};
            
            cfg.precision                                   = 'single' ;                 % single precision data for memory efficiency
            hc_data                                         = ft_preprocessing(cfg);
            
            cfg                                             = [];
            cfg.resamplefs                                  = 300 ;
            cfg.detrend                                     = 'no';                      % to be explicitly mentioned
            cfg.demean                                      = 'no';
            hc_data                                         = ft_resampledata(cfg,hc_data);
            
            hc_data                                         = rmfield(hc_data,'cfg');
            
            dir_data                                        = ['../data/' suj '/preprocessed/'];
            fname                                           = [dir_data suj '_hc_data_' modality '.mat'];
            fprintf('saving %s \n',fname);
            save(fname,'hc_data','-v7.3');
            
            clear hc_data trialinfo
            
        end
        
    end
end