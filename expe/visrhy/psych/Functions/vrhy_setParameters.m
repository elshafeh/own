function vrhy_setParameters

global wPtr scr stim ctl Info

sizeDisplay                 = [52.7, 29.6]; % LED screens used in the Donders

if strcmp(Info.debug,'no')
    rectDisplay             = [];
else
    rectDisplay             = [20 150 600 600];
end

viewDistance                = 57; % in centimeters
calibFile                   = 'calib_30-Apr-2019.mat';

% === Open screen
if IsLinux
    Screen('Preference', 'SkipSyncTests', 0);
else
    Screen('Preference', 'SkipSyncTests', 1);
end

scr.idx                     = max(Screen('Screens'));
scr.calib_file              = calibFile;
scr.mpc_map_list            = JY_VisExptTools('ComputeGammaTable', scr);

[wPtr, scr.rect]            = Screen('OpenWindow',scr.idx, [], rectDisplay, [], [], [], 8);
[scr.xCtr, scr.yCtr]        = RectCenter(scr.rect); % the center pixel

Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('LoadCLUT', wPtr, scr.mpc_map_list);
Screen('TextSize', wPtr, 40);
MaxPriority(wPtr);

Screen('BlendFunction', wPtr, 'GL_ONE');

% === Set Colors
scr.black                   = BlackIndex(wPtr);
scr.white                   = WhiteIndex(wPtr);
scr.gray                    = (scr.white + scr.black)./2;
scr.lightgray               = scr.gray./2;
scr.blue                    = [47 141 255];
scr.green                   = [169 255 47];
scr.background              = scr.gray/2;

scr.green                   = [0,255,0];
scr.red                     = [255,0,0];

scr.ifi                     = Screen('GetFlipInterval', wPtr);
scr.size                    = sizeDisplay;
scr.bgColor                 = repmat(scr.gray, [1,3]);
scr.viewDist                = viewDistance; %in cm

scr.rect_width              = 180;
scr.xShift                  = 250;
scr.yShift                  = 0;


% === Set Pixels
cfg                         = scr;
cfg.degrees                 = [1,1]; % the scale (pixels per degree)
scr.ppdXY                   = JY_VisExptTools('deg2Pixel',cfg);
scr.ppdX                    = mean(scr.ppdXY);
scr.ppdY                    = mean(scr.ppdXY);

% === Fixation Bull
stim.Fix.size               = round(0.6 * scr.ppdX) * 3;
stim.Fix.type               = 'cross';
stim.Fix.mask               = ones(stim.Fix.size+2, stim.Fix.size+2, 2); %+2 to ensure no obvious edge cause by cropping
stim.Fix.mask(:,:,1)        = stim.Fix.mask(:,:,1) .* scr.gray;
stim.Fix.mask(:,:,2)        = zeros( size(stim.Fix.mask(:,:,2)));
stim.Fix.PossibColor        = {scr.black,scr.white}; % to be played with targets

% === Durations
stim.dur.stim               = scr.ifi * 2;
stim.dur.iti                = round(2 ./ scr.ifi) * scr.ifi;
stim.dur.pause              = round(1 ./ scr.ifi) * scr.ifi;
stim.dur.resp               = 2; % response window
stim.dur.fix                = round(0.2 ./ scr.ifi) * scr.ifi; % 200 ms

% === Control
KbName('UnifyKeyNames');
ctl.DeviceNum               = -1;
ctl.keyQuit                 = KbName('q');
ctl.keyContinue             = KbName('space');
ctl.key1                    = KbName('j');
ctl.key2                    = KbName('k');
ctl.keyValid                = [ctl.key1, ctl.key2]; 
if IsLinux
   ctl.keyValid             = [ctl.keyContinue, ctl.keyQuit]; 
end
ctl.mapping                 = mod(str2num(Info.name(end)),2) + 1; % 1 = letter left. 2 = letter right.
ctl.buttonCodesOn           = [97, 98, 99, 100];
ctl.buttonCodesOff          = [65, 66, 67, 68];

% === Set Instructions
InstructConc            = '\n\nPlease Fixate To The Center of The Screen\n\n\nPress any button to continue';
if ctl.mapping == 1
    disp('Letter will be left')
    scr.Pausetext           = ['Press Left for letters\n\nPress Right for numbers\n\nDo not respond to numbers equal to 0' InstructConc];
else
    disp('Letter will be right')
    scr.Pausetext           = ['Press Left for numbers\n\nPress Right for letters\n\nDo not respond to numbers equal to 0' InstructConc];
end