function [experimentResults]=rhythmInterval_speeded_mod(subjectNum)

% for desktop GPU, trial running on frames
% Additions:
% 1. possibility to change display size (helpful for debugging): params.Screen.WinSize
% 2. Expected keys to ease the choise of block: practice, full
% etc.
% 3. Add 'Press Key To Continue' when initializing ptb
% 4. Getting Responses from dccn's bitsi response devices

% Update: Hesham ElShafei 7 June 2019

global params

%% parameters
params.Screen.background                = [0.3, 0.3, 0.3];
params.Screen.escapeKey                 = KbName('ESCAPE');

params.Stim.stimSize                    = 100;
params.Stim.nRhythmicStimuli            = 4;
params.Stim.stimColors                  = [0.5, 0.2, 0.2; 0.9, 0.9, 0.9; 0.1, 0.5, 0.2; params.Screen.background];

params.Time.cue                         = [0.6; 0.9]; % target intervals
params.Time.ISI                         = [1.3 1.4 1.5 1.6 1.7; 1.95 2.1 2.25 2.4 2.55]; % inter-pair interval in interval condition
params.Time.tarIntervalRand             = [0.4 0.5 0.6 0.7 0.8; 0.6 0.75 0.9 1.05 1.2];  % target time randomization in random condition
params.Time.cueJitter                   = [0.4 0.5 0.6 0.7 0.8; 0.6 0.75 0.9 1.05 1.2];  % cue time randomization in random condition
params.Time.tar                         = 0.15;
params.Time.ITI                         = [0.8 1.1 1.4];
params.Time.respWindow                  = 3;
params.Time.waitCatch                   = 1;

params.Screen.randInstructFull          = ['In each trial, you will see flashing colored squares:\na few red squares, a white square and a green square\n\n'...
    'Your goal is to press the enter button as fast\nas you can when you see the green square\n\n'...
    'The green square will only appear after the white\nwhen you see the white, get ready for the green\n\n'...
    'In some trials, there will be no green square\nIn this case dont press anything'];

params.Screen.useRhythmInstructFull     = ['Rhythm condition\n\n'...
    'Your goal is to press the enter button as fast\nas you can when you see the green square\n\n'...
    'The squares will appear with a fixed pace,\nforming a rhythm\n\n'...
    'Try to synchronize with the rhythm to anticipate\nthe time of the green square, and be prepared\nfor it at the right time\n\n'...
    'However, dont just press out of anticipation\nas sometimes there will be no green square'...
    ];
params.Screen.useIntervalInstructFull   = ['Interval condition\n\n'...
    'Your goal is to press the enter button as fast\nas you can when you see the green square\n\n'...
    'In each trial, the delay between the two\nred squares will be identical to the delay\nbetween the white and the green squares\n\n'...
    'Try to remember how long it took between the\nred squares, and use that to be prepared for\nthe green square at the right time\n\n'...
    'However, dont just press out of anticipation\nas sometimes there will be no green square'...
    ];

params.Screen.randInstruct              = 'press as fast as you can for green';
params.Screen.useRhythmInstruct         = 'use rhythm to anticipate the time\n of the green square';
params.Screen.useIntervalInstruct       = 'use interval to anticipate the time\n of the green square';


% add Bitsi for box response

if IsLinux
    try
        params.b   = Bitsi('/dev/ttyS0');
    catch
        fclose(instrfind);
        params.b   = Bitsi('/dev/ttyS0');
    end
end


%% design params
% create block structure
blockTriplet    = [3 1 2]; % 1=rhythm, 2=interval, 3=random
nTriplets       = 3;
blocks          = [];

for b=1:nTriplets
    if rand > 0.5 %randomize block order, random always first in triplet
        blocks=[blocks, blockTriplet([1 2 3])];
    else
        blocks=[blocks, blockTriplet([1 3 2])];
    end
end

% create design matrix
% 1. cueType (1 = rhythm, 2 = interval)
% 2. cueInterval (1 = short, 2 = long)
% 3. tarTiming (0 = on time, 2 = catch)
blockConds                      = {[1] [1 2] [0 0 0 0 0 0 0 0 0 0 0 0 2 2 2 2]}; %factor levels
[BlockTrialList,BlockLength]    = createTrialList(blockConds);


%% check for existing file
fileNameAll     = sprintf('rhythmInterval_speeded_s%d',subjectNum);

dirContent=dir;

for i=3:size(dirContent,1)
    currentFile = dirContent(i).name;
    if strcmp(currentFile  ,[fileNameAll '.mat'])
        sca
        error('file name already exists!')
    end
end


%% initialize PTB
Screen('Preference', 'SkipSyncTests', 1);
Priority(1);
PsychDefaultSetup(2);

rng('shuffle')

% take over screen
screenNumber                                        = max(Screen('Screens'));

params.Screen.WinSize                               = []; %[20 20 600 600]; % 

[params.Screen.window, params.Screen.windowRect]    = PsychImaging('OpenWindow', screenNumber, params.Screen.background, params.Screen.WinSize, 32, 2, [], [],  kPsychNeed32BPCFloat);
Screen('Flip', params.Screen.window);

params.Screen.ifi                                   = Screen('GetFlipInterval', params.Screen.window);

params.Screen.black = BlackIndex(screenNumber);
[x, y] = RectCenter(params.Screen.windowRect);
params.Screen.xyCenter=[x,y];
Screen('TextSize', params.Screen.window, round(params.Screen.windowRect(4)/20));


%% prepare stimuli
%convert time to frames
params.Time.cueFrames=round(params.Time.cue/params.Screen.ifi);
params.Time.ISIFrames=round(params.Time.ISI/params.Screen.ifi);
params.Time.tarIntervalRandFrames=round(params.Time.tarIntervalRand/params.Screen.ifi);
params.Time.cueJitterFrames=round(params.Time.cueJitter/params.Screen.ifi);
params.Time.tarFrames=round(params.Time.tar/params.Screen.ifi);

% prepare offscreen stimuli
for s=1:size(params.Stim.stimColors,1)
    currentStim=[];
    currentStim(:,:,1)=params.Stim.stimColors(s,1)*ones(params.Stim.stimSize,params.Stim.stimSize);
    currentStim(:,:,2)=params.Stim.stimColors(s,2)*ones(params.Stim.stimSize,params.Stim.stimSize);
    currentStim(:,:,3)=params.Stim.stimColors(s,3)*ones(params.Stim.stimSize,params.Stim.stimSize);
    params.Stim.stimOffscreens(s)=Screen('MakeTexture', params.Screen.window, currentStim);
end

%%%%%%%%%%%%% end preparations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% start experiment
DrawFormattedText(params.Screen.window, 'Press Any Key To Continue', 'center', 'center', params.Screen.black);
Screen('Flip', params.Screen.window);

if IsLinux
    BitsiGet(1);
else
    KbStrokeWait;
end

if IsLinux
    params.b.clearResponses();
end

ShowCursor(0);
HideCursor;
Screen('Flip', params.Screen.window);

experimentResults           = [];
params.experimentTiming     = {};

%main loop on blocks, practice within each block
for currentBlock = 1:length(blocks)
    
    if IsLinux
        params.b.clearResponses();
    end
    
    %set block type
    currentBlockTrialList       = BlockTrialList;
    currentBlockLength          = BlockLength;
    
    currentBlockTrialList(:,1)  = blocks(currentBlock); %set condition type
    
    switch blocks(currentBlock) %instructions
        case 1
            instructFull        = params.Screen.useRhythmInstructFull;
            instruct            = params.Screen.useRhythmInstruct;
        case 2
            instructFull        = params.Screen.useIntervalInstructFull;
            instruct            = params.Screen.useIntervalInstruct;
        case 3
            instructFull        = params.Screen.randInstructFull;
            instruct            = params.Screen.randInstruct;
    end
    
    DrawFormattedText(params.Screen.window, instructFull, 'center', 'center', params.Screen.black);
    Screen('Flip', params.Screen.window);
    
    if IsLinux
        BitsiGet(1);
    else
        KbStrokeWait;
    end
    
    Screen('Flip', params.Screen.window);
    pause(1)
    
    % preliminary practice
    pract=1;
    while pract
        
        DrawFormattedText(params.Screen.window, 'practice (Short(s)/Full(f)/No(n)/Exit(9))?', 'center', 'center', params.Screen.black); %first letter determines what to do
        Screen('Flip', params.Screen.window);
        [~, keyName, ~]= KbStrokeWait;
        
        if strcmp(KbName(keyName), '9')==1 % exit
            sca;
            return
        elseif strcmp(KbName(keyName), 'n')==1 % run experiment block
            pract=0;
        elseif strcmp(KbName(keyName), 'f')==1 || strcmp(KbName(keyName), 's')==1 % practice
            
            practiceTrialList = [ones(6,1)*blocks(currentBlock), [1 2 2 1 1 2]', [0 0 0 2 0 2]'];
            if strcmp(KbName(keyName), 's')==1
                practiceTrialList=practiceTrialList(1:2,:);
            end
            
            Screen('FillRect', params.Screen.window, params.Screen.background);
            DrawFormattedText(params.Screen.window, instruct, 'center', 'center', params.Screen.black);
            Screen('Flip', params.Screen.window);
            
            if IsLinux
                BitsiGet(1);
            else
                KbStrokeWait;
            end
            
            Screen('FillRect', params.Screen.window, params.Screen.background);
            Screen('Flip', params.Screen.window);
            pause(1)
            
            for pracTrial=1:size(practiceTrialList,1)
                
                if IsLinux
                    params.b.clearResponses();
                end
                
                pause(params.Time.ITI(ceil(length(params.Time.ITI)*rand)));
                
                switch practiceTrialList(pracTrial,1)
                    case 1
                        [resp, RT] = trialProcRhythm(practiceTrialList(pracTrial,2),practiceTrialList(pracTrial,3),1);
                    case 2
                        [resp, RT] = trialProcIntervalEmpty(practiceTrialList(pracTrial,2), practiceTrialList(pracTrial,3),1);
                    case 3
                        [resp, RT] = trialProcRhythm(practiceTrialList(pracTrial,2),practiceTrialList(pracTrial,3),0);
                end
                
                disp(num2str(1000*RT));
                
                Screen('Flip', params.Screen.window);
                
                %provide feedback
                if resp==-1
                    DrawFormattedText(params.Screen.window, 'Dont press too early', 'center', 'center', params.Screen.black);
                    Screen('Flip', params.Screen.window);
                    pause(1)
                    Screen('Flip', params.Screen.window);
                else
                    if practiceTrialList(pracTrial,3)==2
                        if resp==1
                            DrawFormattedText(params.Screen.window, 'Respond only to targets', 'center', 'center', params.Screen.black);
                            Screen('Flip', params.Screen.window);
                            pause(1)
                            Screen('Flip', params.Screen.window);
                        end
                    else
                        if resp==0 && RT~=-1
                            DrawFormattedText(params.Screen.window, 'No button was pressed', 'center', 'center', params.Screen.black);
                            Screen('Flip', params.Screen.window);
                            pause(1)
                            Screen('Flip', params.Screen.window);
                        end
                    end
                end
                
                % for practice a second response is needed to move for the
                % next trial
                if IsLinux
                    BitsiGet(1);
                else
                    KbStrokeWait;
                end
                
                pause(0.5);
                
            end
        end
    end %practice done
    
    conditionsMet=0; %shuffle design matrix
    while ~conditionsMet
        mixedBlock=currentBlockTrialList(randperm(currentBlockLength), :);
        catchConseq=max(diff(find(mixedBlock(:,3)==0))-1);
        if catchConseq<3
            conditionsMet=1;
        end
    end
    
    % experimental block
    DrawFormattedText(params.Screen.window, 'Begin block', 'center', 'center', params.Screen.black);
    Screen('Flip', params.Screen.window);
    
    if IsLinux
        BitsiGet(1);
    else
        KbStrokeWait;
    end
    
    Screen('FillRect', params.Screen.window, params.Screen.background);
    DrawFormattedText(params.Screen.window, instruct, 'center', 'center', params.Screen.black);
    Screen('Flip', params.Screen.window);
    pause(2)
    Screen('Flip', params.Screen.window);
    pause(1);
    
    for expTrial=1:currentBlockLength % loop on trials within experimental block
        
        if IsLinux
            params.b.clearResponses();
        end
        
        pause(params.Time.ITI(ceil(length(params.Time.ITI)*rand)));
        
        switch mixedBlock(expTrial,1)
            case 1
                [resp, RT, trialTargetFrame,logKeep]    = trialProcRhythm(mixedBlock(expTrial,2),mixedBlock(expTrial,3),1);
            case 2
                [resp, RT, trialTargetFrame,logKeep]    = trialProcIntervalEmpty(mixedBlock(expTrial,2), mixedBlock(expTrial,3),1);
            case 3
                [resp, RT, trialTargetFrame,logKeep]    = trialProcRhythm(mixedBlock(expTrial,2),mixedBlock(expTrial,3),0);
        end
        
        params.experimentTiming{end+1}                         = logKeep;
        
        Screen('FillRect', params.Screen.window, params.Screen.background);
        Screen('Flip', params.Screen.window);
        
        % provide feedback
        if resp==-1
            DrawFormattedText(params.Screen.window, 'Dont press too early', 'center', 'center', params.Screen.black);
            Screen('Flip', params.Screen.window);
            pause(1)
            Screen('Flip', params.Screen.window);
        else
            if mixedBlock(expTrial,3)==2
                if resp==1
                    DrawFormattedText(params.Screen.window, 'Respond only to targets', 'center', 'center', params.Screen.black);
                end
                Screen('Flip', params.Screen.window);
                pause(1)
                Screen('Flip', params.Screen.window);
            else
                if resp==0 && RT~=-1
                    DrawFormattedText(params.Screen.window, 'No button was pressed', 'center', 'center', params.Screen.black);
                end
                Screen('Flip', params.Screen.window);
                pause(1)
                Screen('Flip', params.Screen.window);
            end
        end
        
        resp = double(resp);
        
        % save after every trial
        % 1) nb suj, 2) nb block, 3) bloc type, 4) nb trial, 5) -1?,
        % 6) cueType (1 = rhythm, 2 = interval) ,
        % 7) cueInterval (1 = short, 2 = long) ,
        % 8) tarTiming (0 = on time, 2 = catch) ,
        % 9) button , 10) RT , 11) ??
        
        trialResults        = [subjectNum, currentBlock, blocks(currentBlock), expTrial, -1, mixedBlock(expTrial,1), mixedBlock(expTrial,2), mixedBlock(expTrial,3), resp, RT, trialTargetFrame];
        experimentResults   = [experimentResults; trialResults];
        
        save([fileNameAll '.mat'], 'experimentResults', 'params');
        
    end
    
    DrawFormattedText(params.Screen.window, 'Take a break', 'center', 'center', params.Screen.black);
    Screen('Flip', params.Screen.window);
    
end % end loop on blocks

if IsLinux
    BitsiGet(1);
else
    KbStrokeWait;
end

sca
clear mex


%%
function [resp, RT, targetIntervalFrames,logKeep] = trialProcRhythm(cueISI, tarISI, trialType)

global params

resp    =   0;
RT      =   -1;

if trialType == 1
    cueCode     = 100 + (cueISI*10) + tarISI;
else
    cueCode     = (cueISI*10) + tarISI;
end

%% trial-specific preparations
if trialType==1 %periodic
    stimOnFrames=params.Time.cueFrames(cueISI)*[1:params.Stim.nRhythmicStimuli-1];
else %aperiodic
    previousISI=0;
    for s=1:params.Stim.nRhythmicStimuli-1
        currentPossibleISI=setdiff(params.Time.cueJitterFrames(cueISI,:), previousISI);
        stimOnFrames(s)= currentPossibleISI(ceil(length(currentPossibleISI)*rand));
        previousISI=stimOnFrames(s);
    end
    stimOnFrames=cumsum(stimOnFrames);
end

stimOffFrames=[params.Time.tarFrames, stimOnFrames+params.Time.tarFrames];

if tarISI==2 %catch trial
    targetIntervalFrames = params.Time.cueFrames(cueISI); %set target interval
    waitForResp=params.Time.waitCatch;
else % non-catch
    if trialType==0
        targetIntervalFrames = params.Time.tarIntervalRandFrames(cueISI, ceil(size(params.Time.tarIntervalRandFrames,2)*rand)); %set target interval
    else
        targetIntervalFrames = params.Time.cueFrames(cueISI); %set target interval
    end
    waitForResp=params.Time.respWindow;
end
trialTargetFrame=stimOnFrames(end) + targetIntervalFrames;


%% start trial
responded       = 0;
modCode         = 0;

logCode         = [];
tStim           = [];

Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(1)); %first stimulus

params.b.sendTrigger(cueCode); % send 1st trigger
Screen('Flip', params.Screen.window, [], 1);

startEarly      = GetSecs;

logCode(1)      = cueCode;
tStim(1)        = startEarly;

for frame=1:trialTargetFrame-1 %loop on frames
    
    if modCode  ~= 0
        params.b.sendTrigger(modCode); % send cue trigger
    end
    
    logCode(frame+1)    = modCode;
    tStim(frame+1)      = Screen('Flip', params.Screen.window, [], 1);
    
    if ismember(frame, stimOnFrames)
        if frame==stimOnFrames(end)
            Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(2));
            modCode             = 50;
        else
            Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(1));
            modCode             = cueCode;
        end
    elseif ismember(frame, stimOffFrames)
        Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(4));
    else
        modCode                 = 0;
    end
    
    % check for early response
    if IsLinux
        keyDown             = BitsiGet(0);
    else
        keyDown             = KbCheck;
    end
    
    if keyDown
        RT                  = GetSecs-startEarly-trialTargetFrame*params.Screen.ifi;
        resp                =-1;
        logKeep             = NaN;
        return
    end
    
end

if ~(tarISI==2) %present target if not catch
    Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(3));
    tarCode     = 61;
else
    Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(4));
    tarCode     = 60;
end

params.b.sendTrigger(tarCode); % send cue trigger
Screen('Flip', params.Screen.window, [], 0, 2);
tStim(end+1)    = GetSecs;
logCode(end+1)  = tarCode;

tStim           = tStim-startEarly;
logKeep         = [logCode' tStim'];
logKeep         = logKeep(logKeep(:,1) ~= 0,:); clear tStim logCode;

% get response
startTime       =   GetSecs;

while ~responded
    
    [keyDown,~]     = params.b.getResponse(waitForResp,1);
    currentTime     =GetSecs-startTime;
    
    if keyDown
        RT          =currentTime;
        resp        =1;
        responded   =1;
    end
    
    if currentTime >= waitForResp %max response window
        RT          =0;
        resp        =0;
        responded   =1;
    end
    
    
end

Screen('FillRect', params.Screen.window, params.Screen.background);
Screen('Flip', params.Screen.window);


%%
function [resp, RT, targetIntervalFrames,logKeep] = trialProcIntervalEmpty(cueISI, tarISI, trialType)

global params

resp                =0;
RT                  =-1;
cueCode             = 200 + (cueISI*10) + tarISI;

%% trial-specific preparations
if trialType==1 % fixed interval
    trialS2onsetFrame=params.Time.cueFrames(cueISI); % set S1 length
else % jittered interval
    trialS2onsetFrame=params.Time.cueJitterFrames(cueISI,ceil(size(params.Time.cueJitterFrames,2)*rand));
end

trialWSOnsetFrame=trialS2onsetFrame + params.Time.ISIFrames(cueISI, ceil(size(params.Time.ISIFrames,2)*rand) ); %set ISI

stimOnFrames=[trialS2onsetFrame trialWSOnsetFrame];
stimOffFrames=[params.Time.tarFrames stimOnFrames+params.Time.tarFrames];

if tarISI==2 %catch trial
    targetIntervalFrames = params.Time.cueFrames(cueISI); %set target interval
    waitForResp=params.Time.waitCatch;
else % non-catch
    if trialType==0
        targetIntervalFrames = params.Time.tarIntervalRandFrames(cueISI, ceil(size(params.Time.tarIntervalRandFrames,2)*rand));
    else
        targetIntervalFrames = params.Time.cueFrames(cueISI); %set target interval
    end
    waitForResp=params.Time.respWindow;
end
trialTargetFrame=stimOnFrames(end) + targetIntervalFrames;


%% start trial
responded       =0;
modCode         = 0;
logCode         = [];
tStim           = [];

Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(1)); %first stimulus

params.b.sendTrigger(cueCode); % send 1st trigger
Screen('Flip', params.Screen.window, [], 1);
startEarly=GetSecs;

logCode(1)      = cueCode;
tStim(1)        = startEarly;

for frame=1:trialTargetFrame-1 %loop on frames
    
    if modCode  ~= 0
        params.b.sendTrigger(modCode); % send cue trigger
    end
    
    logCode(frame+1)  = modCode;
    tStim(frame+1)    = Screen('Flip', params.Screen.window, [], 1, 0);
    
    if ismember(frame, stimOnFrames)
        if frame==trialS2onsetFrame
            Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(1));
            modCode             = cueCode;
        else
            Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(2));
            modCode             = 50;
        end
    elseif ismember(frame, stimOffFrames)
        Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(4));
    else
        modCode                 = 0;
    end
    
    % check for early response
    if IsLinux
        keyDown             = BitsiGet(0);
    else
        keyDown             = KbCheck;
    end
    
    if keyDown
        RT                  =GetSecs-startEarly-trialTargetFrame*params.Screen.ifi;
        resp                =-1;
        logKeep             = NaN;
        return
    end
    
end

if ~(tarISI==2) %present target if not catch
    Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(3));
    tarCode     = 61;
else
    Screen('DrawTexture', params.Screen.window, params.Stim.stimOffscreens(4));
    tarCode     = 60;
end

params.b.sendTrigger(tarCode); % send cue trigger
Screen('Flip', params.Screen.window, [], 0, 2);

tStim(end+1)    = GetSecs;
logCode(end+1)  = tarCode;

tStim           = tStim-startEarly;
logKeep         = [logCode' tStim'];
logKeep         = logKeep(logKeep(:,1) ~= 0,:); clear tStim logCode;

% get response
startTime=GetSecs;

while ~responded
    
    [keyDown,~]     = params.b.getResponse(waitForResp,1);
    currentTime     =GetSecs-startTime;
    
    if keyDown
        RT          =currentTime;
        resp        =1;
        responded   =1;
    end
    
    if currentTime >= waitForResp %max response window
        RT          =0;
        resp        =0;
        responded   =1;
    end
end

Screen('FillRect', params.Screen.window, params.Screen.background);
Screen('Flip', params.Screen.window);


%% auxilliary functions

function  [trialList,BlockLength,numConditions]=createTrialList(conditions)
%creates a matrix with all possible combinations of
%conditions orthogonally

numConditions=size(conditions,2);
[~,condLevels]=cellfun(@size, conditions);
BlockLength=prod(condLevels);

trialList=zeros(BlockLength,numConditions);
factor=1;
for i=1:numConditions
    blockSize=BlockLength/factor;
    levelsInBlock=blockSize/condLevels(i);
    for j=1:factor
        for k=1:condLevels(i)
            for l=1:levelsInBlock
                current=conditions{i};
                trialList((j-1)*blockSize+(k-1)*levelsInBlock+l,i)=current(k);
            end
        end
    end
    factor=factor*condLevels(i);
end

% get or wait for response from bitsi device
function keyDown = BitsiGet(KeyWait)
% this captures responses from
% response device in DCCN behavioral cubicles

global params

if KeyWait
    [keyDown,~]             = params.b.getResponse(120*120,1);
    [KeyUp,~]               = params.b.getResponse(120*120,1);
else
    [keyDown,~]             = params.b.getResponse(0.00001,1);
    [KeyUp,~]               = params.b.getResponse(0.00001,1);
end