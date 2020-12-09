% automatically detects subject with a raw .ds folder
% and saves data as .mat with:
% * single precision
% * 300Hz downsampling
% * band-stop 50 100 150Hz
% * behavior added into trialinfos

if ispc
    start_dir = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir = '~/Dropbox/project_me/data/taco/';
end

suj_list                                        = dir([start_dir '/ds/*ds']);

for ns = 1:length(suj_list)
    
    subjectName                           	= suj_list(ns).name(1:6);
    
    ds_dir                                	= [start_dir 'ds/'];
    preproc_dir                          	= [start_dir 'preproc/'];
    
    % check that subject has not been preprocessed
    chk_preproc                          	= dir([preproc_dir subjectName '*_finalrej.mat']);
    
    if isempty(chk_preproc)
        
        % check that .ds has not been conevrted to .mat already
        chk_mat                          	= dir([preproc_dir subjectName '*_raw_dwnsample.mat']);
        
        if isempty(chk_mat)
            
            %                 h_makesubjectdirectory(subjectName);
            
            dsFileName                   	= dir([ds_dir subjectName '*.ds']);
            dsFileName                  	= [dsFileName.folder '/' dsFileName.name];
            
            % check that trigger timings are good :)
            [hdr,events]                 	= taco_fun_checktiming(dsFileName);
            
            % lock to first cue and add behavior in trial info
            [all_cfg]                       = taco_func_definetrial(dsFileName);
            [clean_cfg]                   	= taco_func_addbehav(subjectName,all_cfg,hdr,events);
            
            cfg_dir                         = preproc_dir;
            save([cfg_dir subjectName '_allTrialInfo.mat'],'clean_cfg','-v7.3');
            
            % bandstop filter line-noise
            % save data as single precision to save space
            % once for 1st cue locked and once for localizer
            
            list_lock                       = [1 8];
            
            for nl = 1:length(list_lock)
                
                cfg                         = [];
                cfg.dataset                 = dsFileName;
                cfg.trl                     = clean_cfg.trl{list_lock(nl)};
                cfg.channel               	= {'MEG'};
                cfg.continuous            	= 'yes';
                cfg.bsfilter             	= 'yes';
                cfg.bsfreq               	= [49 51; 99 101; 149 151];
                cfg.precision             	= 'single';
                data                       	= ft_preprocessing(cfg);
                
                % DownSample to 300Hz
                cfg                      	= [];
                cfg.resamplefs          	= 300;
                cfg.detrend               	= 'no';
                cfg.demean                	= 'no';
                data_downsample          	= ft_resampledata(cfg, data); clear data;
                
                % Save data
                fname                    	= [preproc_dir subjectName '_' clean_cfg.list{list_lock(nl)} 'lock_raw_dwnsample.mat'];
                fprintf('\nSaving %s\n',fname);
                save(fname,'data_downsample','-v7.3');
                
            end
        end
    end
end

fprintf('\nall caught up! :) \n\n');

% quickly plot behavioral data for quick check
% bil_quickbehavcheck;