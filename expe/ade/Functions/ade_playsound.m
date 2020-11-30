function ade_playsound(SoundFile,P,TargetCode)
% Function to play Sound


% (1) loads data into buffer
PsychPortAudio('FillBuffer', P.pahandle,SoundFile);
% (2) set volume
PsychPortAudio('Volume',P.pahandle,P.SoundVolume);
% (3) starts sound immediatley for 1 repition + send trigger
% PsychPortAudio('Start', P.pahandle, 1,0);
PsychPortAudio('Start', P.pahandle, 1,0,0);

P.bitsi.sendTrigger(TargetCode);