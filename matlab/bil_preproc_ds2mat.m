function bil_preproc_ds2mat

% automatically detects subject with a raw .ds folder
% and saves data as .mat with:
% * single precision
% * 300Hz downsampling
% * band-stop 50 100 150Hz
% * behavior added into trialinfos

if ispc
    start_dir = 'P:\';
else
    start_dir = '/project/';
end

suj_list                                        = [dir([start_dir '3015079.01/raw/sub*ds']); ... 
    dir([start_dir '3015079.01/raw/sub-*/ses-meg01/meg/*ds'])];

for ns = 1:length(suj_list)
    
    subjectName                                 = suj_list(ns).name(1:6);
    
    chk_preproc                                 = dir([start_dir '3015079.01/data/' subjectName '/preproc/*_finalrej.mat']);
    
    % check that subject has not been preprocessed
    if isempty(chk_preproc)
        
        chk_mat                                 = dir([start_dir '3015079.01/data/' subjectName '/preproc/*_raw_dwnsample.mat']);
        
        % check that .ds has not been conevrted to .mat already
        if isempty(chk_mat)
            
            try
                
                h_makesubjectdirectory(subjectName);
                
                if strcmp(subjectName,'sub007')
                    dir_data                    = '/home/mrphys/hesels/';
                elseif strcmp(subjectName,'sub037')
                    dir_data                    = [start_dir '3015079.01/raw/sub-037/ses-meg01/meg/'];
                else
                    dir_data                    = [start_dir '/3015079.01/raw/'];
                end
                
                dsFileName                      = dir([dir_data subjectName '*.ds']);
                dsFileName                      = [dsFileName.folder '/' dsFileName.name];
                
                % check that trigger timings are good :)
                h_timingcheck(dsFileName);
                
                % lock to first cue and add behavior in trial info
                [all_cfg]                       = h_definetrial(dsFileName);
                save([start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_allTrialInfo.mat'],'all_cfg','-v7.3');
                
                
                % bandstop filter line-noise
                % save data as single precision to save space
                
                cfg                             = all_cfg.first_cue;
                cfg.channel                     = {'MEG'};
                cfg.continuous                  = 'yes';
                cfg.bsfilter                    = 'yes';
                cfg.bsfreq                      = [49 51; 99 101; 149 151];
                cfg.precision                   = 'single';
                data                            = ft_preprocessing(cfg);
                
                clearvars -except data subjectName suj_list ns start_dir
                
                % DownSample to 300Hz
                cfg                             = [];
                cfg.resamplefs                  = 300;
                cfg.detrend                     = 'no';
                cfg.demean                      = 'no';
                data_downsample                 = ft_resampledata(cfg, data); clear data;
                
                % Save data
                fname                           = [start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_firstcuelock_raw_dwnsample.mat'];
                fprintf('\nSaving %s\n',fname);
                save(fname,'data_downsample','-v7.3');
                
            catch
                
                fprintf('\n SOMETHING WRONG WITH  %s\n',subjectName);
                
            end
            
        end
    end
end

fprintf('\nall caught up! :) \n\n');

% quickly plot behavioral data for quick check
% bil_quickbehavcheck;