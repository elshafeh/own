function Info  = ade_start

% Initiate the matlab workspace
% takes input about what session would be run , where and how

Screen('CloseAll');

if ismac
    Screen('Preference', 'SkipSyncTests', 1); %% warning : i'm adding this allows running  experiment on  macbook!
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% first prompt

Info                    = struct;
Info.name               = input('Subject name (00 for debug)                :','s');
Info.modality           = input('Modality (aud or vis)                      :','s');
Info.experiment         = input('Session (stair or expe)                    :','s');
Info.screendebug        = input('Debugging Mode (yes or no)                 :','s');
Info.expe_room          = input('Enter recording room (do NOT use spaces)   :','s');
Info.motor_in           = 'yes';

Info.logfolder          = ['Logfiles' filesep 'sub' Info.name];
mkdir(Info.logfolder);

% load volume

vol_info                = load([Info.logfolder filesep 'sub' Info.name '_soundVolume.mat']);
Info.SoundVolume        = vol_info.Info.SoundVolume; clear vol_info;

% second prompt

if strcmp(Info.experiment,'stair')
    Info = ade_prompt_staircase(Info);
else
    Info = ade_prompt_experiment(Info);
end

Info.logfilename        = [Info.logfolder filesep 'sub' Info.name '_' Info.modality '_' Info.experiment '_' Info.runtype '_' num2str(Info.runnumber) '_Logfile.mat'];
Info.parameterfilename  = [Info.logfolder filesep 'sub' Info.name '_' Info.modality '_' Info.experiment '_' Info.runtype '_' num2str(Info.runnumber) '_Parameters.mat'];

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['% YOU ARE RUNNING THE ' upper(Info.experiment) ' ' Info.runtype])
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

WaitSecs(1);