function bpilot_setParameters

global wPtr scr stim ctl Info

sizeDisplay                 = [52.7, 29.6]; % LED screens used in the Donders

if strcmp(Info.debug,'no')
    rectDisplay             = [];
else
    rectDisplay             = [20 20 500 500];
end

viewDistance                = 57; % in centimeters
calibFile                   = 'calib_linuxMEG_30-Apr-2019.mat';

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
MaxPriority(wPtr);

%  Screen('BlendFunction', wPtr, 'GL_ONE');

% === Set Colors
scr.black                   = BlackIndex(wPtr);
scr.white                   = WhiteIndex(wPtr);
scr.gray                    = (scr.white + scr.black)./2;
scr.lightgray               = scr.gray./2;

scr.green                   = [0,255,0];
scr.red                     = [255,0,0];

scr.ifi                     = Screen('GetFlipInterval', wPtr);
scr.size                    = sizeDisplay;
scr.bgColor                 = repmat(scr.gray, [1,3]);
scr.viewDist                = viewDistance; %in cm

% === Set Pixels
cfg                         = [];
cfg                         = scr;
cfg.degrees                 = [1,1]; % the scale (pixels per degree)
scr.ppdXY                   = JY_VisExptTools('deg2Pixel',cfg);
scr.ppdX                    = mean(scr.ppdXY);
scr.ppdY                    = mean(scr.ppdXY);

% === Fixation Bull
stim.Fix.size               = round(0.6 * scr.ppdX) * 5;
stim.Fix.type               = 'hesham_eye';
stim.Fix.mask               = ones(stim.Fix.size+2, stim.Fix.size+2, 2); %+2 to ensure no obvious edge cause by cropping
stim.Fix.mask(:,:,1)        = stim.Fix.mask(:,:,1) .* scr.gray;
stim.Fix.mask(:,:,2)        = zeros( size(stim.Fix.mask(:,:,2)));
stim.Fix.PossibColor        = {scr.black,scr.white}; % to be played with targets

% === Durations
stim.dur.ISI                = round(1.5 ./ scr.ifi) * scr.ifi;
stim.dur.pause              = round(0.5 ./ scr.ifi) * scr.ifi;
stim.dur.InstructionPause   = round(1 ./ scr.ifi) * scr.ifi;
stim.dur.ITI                = round(2 ./ scr.ifi) * scr.ifi;

stim.dur.mask               = round(0.1 ./ scr.ifi) * scr.ifi;

% === Size & Locations
% === Grating

stim.loc.rectDeg            = [0, 0, 20, 20];
stim.loc.rectPix            = ceil(stim.loc.rectDeg .* scr.ppdX);
stim.loc.rect               = CenterRectOnPoint(stim.loc.rectPix, scr.xCtr, scr.yCtr);
stim.loc.outerR             = stim.loc.rectDeg(3)./2;
stim.loc.innerR             = 3./1.5;

stim.patch.sizedeg          = stim.loc.rectDeg(3);
stim.patch.sizepix          = stim.loc.rectPix(3);
stim.patch.ori_kappa        = 500;

stim.patch.patchlum         = 0.5000;

% === Donut
m.innerR                    = stim.loc.innerR;
m.outerR                    = stim.loc.outerR;
m.degSmoo                   = 0.5;
m.maskSiz                   = stim.patch.sizepix;
tmpmask                     = JY_VisExptTools('make_smooth_donut_mask', m);
stim.mask                   = ones( [size(tmpmask), 2] );
stim.mask(:,:,1)            = stim.mask(:,:,1) .* scr.gray/2;
stim.mask(:,:,2)            = tmpmask;

% === Control
KbName('UnifyKeyNames');
ctl.DeviceNum               = -1;
ctl.keyQuit                 = KbName('Q');
ctl.key1                    = KbName('D');
ctl.key2                    = KbName('K'); % KbName(';:'); % CHECK !!!!!!!!!!
ctl.keyValid                = [ctl.key1, ctl.key2]; %, ctl.keyQuit];