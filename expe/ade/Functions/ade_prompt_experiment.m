function Info = ade_prompt_experiment(Info)

Info.runtype                        = input('Experiment type (train or run)             :','s');
Info.runnumber                      = input('Number of run                              :');

if strcmp(Info.runtype,'run')
    if Info.runnumber == 1
        Info.eyefile                    = input('Eye Tracker file(00xmod)                   :','s');
    else
        tmp                             = load([Info.logfolder filesep 'sub' Info.name '_' Info.modality '_expe_run_1_Logfile.mat']);
        Info.eyefile                    = tmp.Info.eyefile;
    end
end

Info.stairuse                       = input('Staircase to use (e.g. extra_1)            :','s');
Info.override                       = input('Override Staircase? (0 or value if yes)    :');

% this is a very important input . if you put '0' nothing happens
% however imagine a case where staircase isn't working , and you want to
% put in an arbitrary value ; this then comes in handy to override the
% automatic read-in of discmrination values form staircase

if Info.override == 0
    
    disc_info                       = load([Info.logfolder filesep 'sub' Info.name '_' Info.modality '_stair_' Info.stairuse '_Logfile.mat']);
    Info.Threshold                  = disc_info.Info.DiscriminationThreshold;
    Info.SemiToneDifference         = disc_info.Info.SemiToneDifference;
    
else
    
    Info.Threshold                  = Info.override;
    
end

if strcmp(Info.modality,'aud')
    Info.Threshold                      = round(Info.Threshold,1);
end