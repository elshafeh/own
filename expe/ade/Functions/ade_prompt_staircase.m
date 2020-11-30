function Info = ade_prompt_staircase(Info)

if strcmp(Info.modality,'aud')
    
    Info.runtype                = input('Staircase type (train or run or extra)     :','s');
    Info.runnumber              = input('Number of run                              :');
    Info.SemiToneDifference     = input('Enter Auditory Semitone-difference         :');
    
else
    
    Info.runtype                = input('Staircase type (train or run or extra)     :','s');
    Info.runnumber              = input('Number of run                              :'); % str2double(answer{2});
    Info.SemiToneDifference     = 0;
    
end

% this is absolutely important to take note of 
% if you're running the extra 

if strcmp(Info.runtype,'extra')
    
    Info.previousrun                = input('Staircase type to build upon(e.g. run_1):','s'); % answer{1};
    
    disc_info                       = load([Info.logfolder filesep 'sub' Info.name '_' Info.modality '_stair_' Info.previousrun '_Logfile.mat']);
    
    Info.Threshold                  = disc_info.Info.DiscriminationThreshold;
    
    if strcmp(Info.modality,'aud')
        Info.Threshold              = round(Info.Threshold,1);
    end
    
else
    
    Info.Threshold                  = 'not set yet';
    
end