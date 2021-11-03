clear;

% define audio parameters

InitializePsychSound;

PsychPortAudio('Close');
P.pahandle            	= PsychPortAudio('Open', [], [], 0, P.toneFs,2);

P.SoundVolume           = 1;
P.VolumeCutoff          = 0.5;

% define display parameters

[wPtr, scr.rect]     	= Screen('OpenWindow',scr.idx, [], rectDisplay, [], [], [], 8);
scr.ifi             	= Screen('GetFlipInterval', wPtr);


t1                      = CueInfo.tcue3 + (ISI-CueInfo.CueDur); % t1 is when u want the target to be played
tPrefix                 = t1;

targeton               	= Screen('Flip',wPtr, tPrefix - (scr.ifi/2)); % scr.ifi = refresh rate

ade_playsound(Target1playNoise',P,TargetCode);

targetoff            	= Screen('Flip', wPtr, targeton + dur.target - scr.ifi/2);


function ade_playsound(SoundFile,P,TargetCode)

% Function to play Sound
% (1) loads data into buffer
PsychPortAudio('FillBuffer', P.pahandle,SoundFile);
% (2) set volume
PsychPortAudio('Volume',P.pahandle,P.SoundVolume);
% (3) starts sound immediatley for 1 repition + send trigger
PsychPortAudio('Start', P.pahandle, 1,0,0);

P.bitsi.sendTrigger(TargetCode);

end