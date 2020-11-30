% = % Set Environment
sca;
clear;

addpath(genpath('Functions/'));
addpath(genpath('Stimuli/'));

global wPtr scr stim ctl Info 

Info.name                                   = input('Subject name                   : ','s');
Info.runtype                                = input('Session (train or block)       : ','s');
Info.lvl                                    = input('Difficulty level               : ');
Info.debug                                  = 'no';
Info.eyetracker                             = 'yes' ;


vrhy_setParameters;
vrhy_start;
vrhy_createStimuli;

if strcmp(Info.debug,'no')
    HideCursor;
end


% = % define in vrhy_start
break_trials                            = 1:Info.bloc_length:length(Info.trialinfo); 

if strcmp(Info.runtype, 'train')
    vrhy_demonstrateStimuli;
else if ~strcmp(Info.runtype, 'block')
        msg = 'Invalid runtype given (must be train or block).';
        error(msg);
    end
end

% Get frequency indices
freqinvs = flip(sort(unique(Info.trialinfo(:,2)))); % Flip because f = 1/info.

if strcmp(Info.runtype, 'block')
    if strcmp(Info.eyetracker, 'yes')
        vrhy_startEyeTracking;
    end
    msg = 'Note to Experimenter:\n\n1) Measure head location\n\n2) Start MEG';
    vrhy_showWarning(msg);
    vrhy_askSleep;
end

% = % Loop Through Trials
for ntrial = 1:length(Info.trialinfo)
    
    % = % this displays instruction at beginning of each block
    if ismember(ntrial,break_trials)       
        tnow = vrhy_BlockStart();
        freq_idx = find(freqinvs == Info.trialinfo(ntrial,2));
        scr.b.sendTrigger(10+freq_idx); % send start block trigger
    else
        tnow = tfin;
    end
        
    % = % get the stimuli and ISI
    trl_stim                                = Info.Stim(ntrial,:); trl_stim = trl_stim(trl_stim ~= 'X');
    trl_isi                                 = Info.ISI(ntrial,:); trl_isi = trl_isi(~isnan(trl_isi));
   
    
    % Darken background and draw fixation
    bgmask                  = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.background);
    Screen('DrawTextures', wPtr,bgmask);
    vrhy_drawFixation;
    t_start_cross = Screen('Flip', wPtr); 
    scr.b.sendTrigger(103); % send fixation onset trigger
    Info.timing{ntrial}                     = [Info.timing{ntrial} t_start_cross];
    
    % Darken background and remove fixation
    bgmask                                  = Screen('MakeTexture', wPtr, ones(scr.rect(4), scr.rect(3)).*scr.background);
    Screen('DrawTextures', wPtr,bgmask);
    t_end_cross                             = Screen('Flip', wPtr, t_start_cross + stim.dur.fix - scr.ifi/2);
    scr.b.sendTrigger(104); % send fixation offset trigger
    Info.timing{ntrial}                     = [Info.timing{ntrial} t_end_cross];
    
    % = % adds in ITI to stimulus onset / gives more accurate estimate
    if strcmp(Info.runtype, 'block')
        cnstnt                                  = t_end_cross + 2.5; % 2.5 seconds between fixation and first zero
    else
        cnstnt                                  = t_end_cross + 1.0; % 1.0 seconds between fixation and first zero
    end
    
    trl_isi                                 = round((trl_isi + cnstnt) ./ scr.ifi) * scr.ifi;
    
    % = % draws number one-by-one
    for ns = 1:length(trl_stim)
        [t1,t2]                             = vrhy_drawstim(trl_stim(ns),trl_isi(ns));
        Info.timing{ntrial}                 = [Info.timing{ntrial} t1 t2]; clear t1 t2;
    end
    
    % = % gets reponse
    [repRT,repButton,repCorrect]            = vrhy_getResponse(Info.expectedRep(ntrial), Info.trialinfo(ntrial,2));

    
    % = % End Trial
    tfin                                    = vrhy_endTrial(repCorrect);
    
    Info.timing{ntrial}                     = [Info.timing{ntrial} tfin];
    Info.rt                                 = [Info.rt;repRT];
    Info.correct                            = [Info.correct;repCorrect];
    Info.button                             = [Info.button;repButton];
    
    
    % = % Break
    if ismember(ntrial,break_trials-1) || ntrial == length(Info.trialinfo)
        toquit = vrhy_BlockEnd([ntrial-Info.bloc_length+1 ntrial]);
        if toquit
            break;
        end 
    end
    clear repRT repCorrect repButton
    
     
end

% = % end experiment and save data (including eye tracking)
vrhy_end;
keep Info;