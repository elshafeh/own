clear ; clc ;

% this is to demonstrate to subjects what auditory targets look like
% ask if the volume is coomfortable
% also ask if they make the difference between the two tones

% to adjust the volume change the parameter in line --> sychPortAudio('Volume',P.pahandle,0.7);
% if volume is changed , you MUST change the volume in ade_parameters P.SoundVolume = xx;

stim_dir                = ['Stimuli' filesep];
list_wavfiles           = {'50ms_target_sound_512_0','50ms_target_sound_542_1','50ms_target_sound_575_2','50ms_target_sound_609_3','50ms_target_sound_645_4'};

if IsLinux
    P.pahandle          = PsychPortAudio('Open',5, [], 2, 44100, 2, 0);
else
    P.pahandle          = PsychPortAudio('Open',[], [], 2, 44100, 2, 0);
end

for nsound = [0 2] % now it's gonna be set to 2
    
    WavName                             = [stim_dir list_wavfiles{nsound+1} '.wav'];
    [tmpWav,toneFs]                     = audioread(WavName);  % load sound file
    tmpWav                              = tmpWav * 0.5;
    
    % (1) loads data into buffer
    PsychPortAudio('FillBuffer', P.pahandle,tmpWav');
    % (2) set volume
    PsychPortAudio('Volume',P.pahandle,1);
    % (3) starts sound immediatley for 1 repition
    PsychPortAudio('Start', P.pahandle, 1,0);
    WaitSecs(0.1);
    
end