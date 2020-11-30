% = % Set Environment

sca;
clear ; clear global;

addpath(genpath('Functions/'));

global wPtr scr stim ctl Info el useEyetrack

Info.name                                   = input('Subject name                                       :','s'); % example sub001
Info.runtype                                = input('Session (train or block)                           :','s'); % training or main experiment
Info.targetcontrast                         = input('Contrast (default=0.4, easy=1, 0<difficult<0.4)    :'); % Target contrast

Info.debug                                  = 'no' ; % if yes you open smaller window (for debugging)
Info.MotorResponse                          = 'yes'; % if no you disable bitsi responses (for debugging)

if strcmp(Info.runtype,'block')
    
    Info.track                              = input('Launch eye-tracking  [y/n]                         :','s'); % launch eye_tracking
    
    if strcmp(Info.track,'y')
        Info.tracknumber                    = input('tracking session number                            :','s'); % keep tracking of how many training sessions
        Info.eyefile                        = [Info.name(4:end) '00' Info.tracknumber];
    end
    
else
    
    Info.runnumber                          = input('training session number                            :','s'); % keep tracking of how many training sessions
    Info.track                              = 'n';
    
end

bpilot_setParameters;
bpilot_start;

if strcmp(Info.track,'y')
    % = % Start Eyetracking
    [el,exitFlag]                           = rd_eyeLink('eyestart', wPtr, Info.eyefile);
    useEyetrack                             = 0;
    if exitFlag, return; end
    
    % = % Calibrate eye tracker
    [cal,exitFlag]                          = rd_eyeLink('calibrate', wPtr, el);
    if exitFlag, return; end
    
    % = % Start recording
    rd_eyeLink('startrecording',wPtr, el);
    useEyetrack                             = 1;
end

% = % Load In / Create Targets beforehand to save time
[TargetStim,ProbeStim,bMask]                = bpilot_CreateAllTargets;

% = % Loop Through Trials

if strcmp(Info.debug,'no')
    HideCursor;
end

ix                                          = 0;

if IsLinux
    scr.b.clearResponses;
end

% just in case during one of the blocks , an error happened and the
% experiment needed to be restarded : this script will make sure to restart
% from the block with the missing trials
strt                                        = bpilot_check_start(Info);

for ntrial = strt:height(Info.TrialInfo)
    
    ix                                      = ntrial; % ix+1;
    
    fprintf('\nTrial no %3d \n\n',ix);
    
    % this to launch the block start instruction sheet
    % this will also launch a page where researcher will have the time to
    % ajust head positions
    
    findvector                              = 1:64:512;
    findix                                  = find(findvector == ntrial);
    
    if ~isempty(findix)
        bloc_number                         = Info.TrialInfo(ix,:).nbloc;
        
        if strcmp(Info.runtype,'block')
            bpilot_headlocaliserbreak;
        end
        
        bpilot_BlockStart(bloc_number);
    end
    
    if IsLinux
        scr.b.clearResponses;
    end
    
    % = % Read in trial type
    CueInfo.CueType                         = Info.TrialInfo(ix,:).cue;
    CueInfo.TaskType                        = Info.TrialInfo(ix,:).task;
    CueInfo.CueDur                          = round(Info.TrialInfo(ix,:).DurCue ./ scr.ifi) * scr.ifi;
    
    stim.dur.target                         = round(Info.TrialInfo(ix,:).DurTar ./ scr.ifi) * scr.ifi;
    
    tmpSRMapping                            = ctl.SRMapping{bloc_number};
    ctl.expectedRep                         = tmpSRMapping(tmpSRMapping(:,2) == Info.TrialInfo(ix,:).match,1);
    
    % = % Draw the first cue
    CueInfo.CueOrder                        = 1;
    
    if ~isempty(findix)
        CueInfo.time_before                 = stim.dur.ITI;
    else
        CueInfo.time_before                 = stim.dur.ITI;
        CueInfo.tfin                        = tfin; clear tfin;
    end
    
    [tcue1,tcue2,tcue3]                     = bpilot_drawcue(CueInfo);
    CueInfo.tcue3                           = tcue3;
    
    if isfield(CueInfo,'tfin')
        CueInfo                             = rmfield(CueInfo,'tfin');
    end
    
    % = % Draw Target/Mask
    stim.patch.FixColor                     = stim.Fix.PossibColor{Info.TrialInfo(ix,:).color};
    stimCode                                = 100 + (10*Info.TrialInfo(ix,:).color) + str2double(Info.TrialInfo(ix,:).tarClass{:}(end));
    
    [t1,t2,t3]                              = bpilot_TrialFun(TargetStim{ntrial},bMask{ntrial,1},stimCode,CueInfo);
    
    Info.TrialInfo.trigtime{ix}             = [Info.TrialInfo.trigtime{ix};tcue1;tcue2;tcue3;t1;t2;t3];
    
    clear tcue1 tcue2 tcue3 t1 t2
    
    % = % Draw the second cue
    CueInfo.time_before                     = stim.dur.ISI-stim.dur.target-stim.dur.mask;
    CueInfo.CueOrder                        = 2;
    CueInfo.tfin                            = t3; clear t3;
    [tcue1,tcue2,tcue3]                     = bpilot_drawcue(CueInfo);
    CueInfo.tcue3                           = tcue3;
    
    if isfield(CueInfo,'tfin')
        CueInfo                             = rmfield(CueInfo,'tfin');
    end
    
    % = % Draw Probe/Mask
    stimCode                                = 200 + (10*Info.TrialInfo(ix,:).color) + str2double(Info.TrialInfo(ix,:).proClass{:}(end));
    [t1,t2,t3]                              = bpilot_TrialFun(ProbeStim{ntrial},bMask{ntrial,2},stimCode,CueInfo);
    
    Info.TrialInfo.trigtime{ix}             = [Info.TrialInfo.trigtime{ix};tcue1;tcue2;tcue3;t1;t2;t3];
    clear tcue1 tcue2 tcue3 t1 t2 t3
    
    % = % Get Response
    if strcmp(Info.MotorResponse,'yes')
        [repRT,repButton,repCorrect]        = bpilot_getResponse;
    else
        repRT                               = 50;
        repButton                           = 51;
        repCorrect                          = 52;
    end
    
    Info.TrialInfo.PresTarg{ix}             = 'ni'; % TargetStim{nblock,ntrial};
    Info.TrialInfo.PresProb{ix}             = 'ni'; % ProbeStim{nblock,ntrial};
    Info.TrialInfo.PresMask{ix}             = 'ni'; % bMask{nblock,ntrial};
    
    Info.TrialInfo.repRT{ix}                = repRT;
    Info.TrialInfo.repButton{ix}            = repButton;
    Info.TrialInfo.repCorrect{ix}           = repCorrect;
    
    ctl.correct                             = repCorrect;
    
    % = % End Trial
    tfin                                    = bpilot_endTrial;
    
    if IsLinux
        scr.b.clearResponses;
    end
    
    findvector                              = 64:64:512;
    findix                                  = find(findvector == ntrial);
    
    % this will end block and save the block information ;
    % after each block it will do that in the background just in case an
    % error occurs.
    
    if strcmp(Info.runtype,'train') && ntrial == height(Info.TrialInfo)
        bpilot_BlockEnd(1:20);
        save(Info.logfilename,'Info','-v7.3');
    else
        if ~isempty(findix)
            bpilot_BlockEnd(ntrial-63:ntrial);
            save(Info.logfilename,'Info','-v7.3');
        end
    end
    
    if IsLinux
        scr.b.clearResponses;
    end
    
end

% = % end experiment and save data (including eye tracking)
if useEyetrack, rd_eyeLink('eyestop', wPtr, {Info.eyefile, Info.eyefolder}); end

sca;
ShowCursor;

clearvars -except Info;

% make sure that performances are saved
save(Info.logfilename,'Info','-v7.3');

% to give idea on behavioral peformances
bpilot_analyzebehav(Info.TrialInfo);