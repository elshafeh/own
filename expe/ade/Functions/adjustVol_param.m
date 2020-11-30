function P = adjustVol_param(Info)
% This function sets all Parameters
%% Display

nscreens                    = 0; 
P.PresentScreen             = nscreens; % to either play on the Macbook screen or external one

rect_size                   = [20 30 400 400]; %[]; % [20 30 400 400]; %
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
% [P.pixperdeg, P.degperpix] 	= VisAng(P); 
% P.pixperdeg                 = mean(P.pixperdeg);
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

P.SemiToneDifference    = 2;
P.ToneDuration          = 0.05;

P                       = ade_load_sounds_expe(P);

InitializePsychSound(0);

if IsLinux
    P.pahandle           = PsychPortAudio('Open',5, [], 2, P.toneFs, 2, 0);
else
    P.pahandle           = PsychPortAudio('Open',[], [], 2, P.toneFs, 2, 0);
end

KbName('UnifyKeyNames');

P.key1  = KbName('1!');
P.key2  = KbName('2@');
P.key3  = KbName('3#');
P.key4  = KbName('4$');