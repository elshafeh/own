function P = ade_load_sounds_stair(P)

P.AllSoundWav           = [];
P.AllSoundName          = {};
P.stim_dir              = ['stimuli' filesep];
list_wavfiles           = {'50ms_target_sound_512_0','50ms_target_sound_542_1','50ms_target_sound_575_2','50ms_target_sound_609_3','50ms_target_sound_645_4'};

for nsound = [0 P.SemiToneDifference] % now it's gonna be set to 2 
    
    WavName                             = [P.stim_dir list_wavfiles{nsound+1} '.wav'];
    [tmpWav,P.toneFs]                   = audioread(WavName);  % load sound file
    P.AllSoundWav                       = cat(3,P.AllSoundWav,tmpWav); 
    P.AllSoundName{end+1}               = WavName;
    clear tmpWav WavName
    
end

P.EmptySound                = zeros(P.toneFs*P.InterToneInterval,2);
tmp(:,:,1)                  = [P.AllSoundWav(:,:,1);P.EmptySound;P.AllSoundWav(:,:,2)]; % low then high 
tmp(:,:,2)                  = [P.AllSoundWav(:,:,2);P.EmptySound;P.AllSoundWav(:,:,1)]; % high then low
P.AllSoundWav               = tmp; clear tmp;