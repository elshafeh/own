function P = ade_param_screen_and_sound(Info)

%% This function sets all Parameters
%% Display

P.experiment                = Info.experiment;
nscreens                    = 0; % Screen('Screens');
P.PresentScreen             = nscreens; % to either play on the Macbook screen or external one

% 'yes' to play full screen and 'no' to play in small rectangle

if strcmp(Info.screendebug,'yes')
    [window,rect]           = Screen(P.PresentScreen,'OpenWindow', [],[20 30 600 600]); % small screen for debugging on laptop
else
    [window,rect]           = Screen(P.PresentScreen,'OpenWindow');
end

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

% This makes sure that on floating point framebuffers we still get a
% well defined gray.:
if P.Grey == P.White
    P.Grey = P.White / 2;
end

P.inc                       = P.White-P.Grey;

myres                       = Screen('Resolution', P.PresentScreen);
P.myWidth                   = myres.width;
P.myHeight                  = myres.height;
P.myRate                    = myres.hz;

P.backgroundColor           = 100; % [100 100 100];

P.res                       = [P.myWidth P.myHeight]; % monitor resolution
P.sz                        = [40 27]; %[round(Screen_w/10) round(Screen_h/10)]; % monitor size in cm
P.vdist 					= 55; % distance of oberver from monitor 
[P.pixperdeg, P.degperpix] 	= VisAng(P); 
P.pixperdeg                 = mean(P.pixperdeg);
P.EccentricityDegree        = 10; %% Where to draw the stimuli %%

if strcmp(Info.screendebug,'yes')
    P.Eccentricity          = round(110);
else
   P.Eccentricity           = round(P.EccentricityDegree * P.pixperdeg(1)); 
end

P.ifi                       = Screen('GetFlipInterval', window); % Query the frame duration

P.TextSize                  = 24;
P.TextColor                 = P.Black; %
P.StuffColor                = [50 50 50];               % Color for everything on the display except targets, e.g. fixation mark.

P.rectangle_width           = 180;
P.shiftX                    = 250;
P.shiftY                    = 0;

P.fixationdiameter          = 4;

%% Volume

if isfield (Info,'SoundVolume')
    P.SoundVolume   = Info.SoundVolume;
else
    P.SoundVolume   = 1;
end

P.VolumeCutoff          = 0.5;
P.motor_in              = Info.motor_in;