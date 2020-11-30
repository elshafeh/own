function P = ade_load_sounds_expe(P)

P.AllSoundWav           = [];
P.AllSoundName          = {};
P.stim_dir              = ['stimuli' filesep];

list_wavfiles           = {'50ms_target_sound_512_0','50ms_target_sound_542_1','50ms_target_sound_575_2','50ms_target_sound_609_3','50ms_target_sound_645_4'};

for nsound = [0 P.SemiToneDifference] 
    
    WavName                             = ['Stimuli/' list_wavfiles{nsound+1} '.wav'];
    [tmpWav,P.toneFs]                   = audioread(WavName);  % load sound file
    P.AllSoundWav                       = cat(3,P.AllSoundWav,tmpWav); 
    P.AllSoundName{end+1}               = WavName;
    clear tmpWav WavName
    
end