clear ; clc;
addpath(['Functions' filesep]);

tic;

if ismac
    Screen('Preference', 'SkipSyncTests', 1); %% warning : i'm adding this allows running  experiment on  macbook!
else
    Screen('Preference', 'SkipSyncTests', 0);
end

%% initiate environment

Info.name                   = input('Subject name:','s');
Info.logfolder              = ['Logfiles' filesep 'sub' Info.name];
mkdir(Info.logfolder);


%% Display

nscreens                    = 0; 
P.PresentScreen             = nscreens; % to either play on the Macbook screen or external one

rect_size                   =  [];  %[20 30 100 100];
[window,rect]               = Screen(P.PresentScreen,'OpenWindow',[],rect_size);

P.window                    = window;
P.rect                      = rect;

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set the blend funciton for the screen
P.glsl                      = MakeTextureDrawShader(window, 'SeparateAlphaChannel'); % Create a special texture drawing shader for masked texture drawing:

[P.CenterX, P.CenterY]      = RectCenter(rect); % rewrite the center since you are using a smaller screen
P.FrDuration                = (Screen( window, 'GetFlipInterval')); % in ms
P.White                     = WhiteIndex(window);
P.Black                     = BlackIndex(window);
P.Grey                      = P.White / 2;
P.Green                     = [0,255,0];
P.Red                       = [255,0,0];

if P.Grey == P.White
    P.Grey = P.White / 2;
end

P.inc                       = P.White-P.Grey;
P.backgroundColor           = 100; % [100 100 100];

myres                       = Screen('Resolution', P.PresentScreen);
P.myWidth                   = myres.width;
P.myHeight                  = myres.height;
P.myRate                    = myres.hz;

P.res                       = [P.myWidth P.myHeight]; % monitor resolution
P.sz                        = [40 27]; %[round(Screen_w/10) round(Screen_h/10)]; % monitor size in cm
P.vdist 					= 55; % distance of oberver from monitor 
P.EccentricityDegree        = 10; %% Where to draw the stimuli %%

P.Eccentricity              = round(110);
P.ifi                       = Screen('GetFlipInterval', window); % Query the frame duration

P.TextSize                  = 24;
P.TextColor                 = [100 100 100];
P.StuffColor                = [50 50 50];               % Color for everything on the display except targets, e.g. fixation mark.

P.rectangle_width           = 180;
P.shiftX                    = 250;
P.shiftY                    = 0;

P.fixationdiameter          = 4;

%% Volume

if isfield(Info,'VolumeCutoff')
    P.VolumeCutoff = Info.VolumeCutoff;
else
    P.VolumeCutoff = 0.5;
end

P.SoundVolume               = 1;
P.StartingThreshold         = 50;

%% load sounds

P.SemiToneDifference        = 3;
P.ToneDuration              = 0.05;

% output is {nsemi}{ntype}{target,1}{threshold_name,2}
load ade_all_soundwaves_0p1step.mat
P.toneFs                    = 44100;
P.AllSoundWav               = AllSounds{P.SemiToneDifference};

InitializePsychSound(0);

if IsLinux
    P.pahandle              = PsychPortAudio('Open',5, [], 2, P.toneFs, 2, 0);
else
    P.pahandle              = PsychPortAudio('Open',[], [], 2, P.toneFs, 2, 0);
end

KbName('UnifyKeyNames');

P.key1  = KbName('1!');
P.key2  = KbName('2@');
P.key3  = KbName('3#');
P.key4  = KbName('4$');

%% start bitsi

if IsLinux
    
    try
        b = Bitsi('/dev/ttyS0');
         fclose(instrfind);
    catch
        fclose(instrfind);
    end
    
    P.bitsi                 = Bitsi('/dev/ttyS0');
    
    %     P.bitsi                 = serial('/dev/ttyS0');      % create serial object
    %     %set(s,'BaudRate',115200,'DataBits',8,'Parity','none','StopBits', 1);% config
    %     set(P.bitsi,'BaudRate',115200);      % this will be enough, the rest is default
    %     fopen(P.bitsi);
    
end

%% Play sounds

for ntype = 1:2
    
    ix_tar                  = [P.AllSoundWav{ntype}{:,2}];
    
    find_tar                = find(ix_tar == round(P.StartingThreshold,1));
    
    Target1playNoise        = P.AllSoundWav{ntype}{find_tar,1};
    
    Target1playNoise        = Target1playNoise* P.VolumeCutoff; % this has been added to adjust volume once noise has been added
    
    ade_playsound(Target1playNoise',P,77);
    
    WaitSecs(0.5); clear Target1playNoise;
    
end


%% Get Feedback

adjVol_presentext(P,'Did you hear two different sounds?');
bprs1                  = adjVol_instruct(P,1);


switch bprs1
    case 4
        sca;
    case 1
        
        flag = 0;
        
        while flag == 0
            
            Target1playNoise        = adjustVol_trial(P);
            adjVol_presentext(P,'Is this volume comfortable for you?');
            bprs2                   = adjVol_instruct(P,1);
            
            switch bprs2
                
                case 1
                    
                    flag = 1;
                    sca;
                    
                case 4
                    
                    WaitSecs(0.2);
                    
                    adjVol_presentext(P,'How would you like to adjust it?');
                    bprs3             = adjVol_instruct(P,2);
                    
                    switch bprs3
                        case 1
                            P.SoundVolume = P.SoundVolume + 0.1;
                        case 4
                            P.SoundVolume = P.SoundVolume - 0.1;
                    end
            end
        end
end

Info.SoundVolume            = P.SoundVolume;
save([Info.logfolder filesep 'sub' Info.name '_soundVolume.mat'], 'Info'); clear ;

if IsLinux
    try
        PsychPortAudio('Close');
    catch
        x   = 0;
    end
end