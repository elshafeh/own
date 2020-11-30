function AllSounds = ade_create_all_sounds

% this function is used to crate all possible sounds
% so that we wouldn't go through the awgn.m and wgn.m functions
% that required the Communication Toolbox which had a whimsical licence

% output is {nsemi}{ntype}{target,1}{threshold_name,2}

for nsemi = 1:4
    
    AllSoundWav                                     = [];
    AllSoundName                                    = {};
    list_wavfiles                                   = {'50ms_target_sound_512_0','50ms_target_sound_542_1',...
        '50ms_target_sound_575_2','50ms_target_sound_609_3',...
        '50ms_target_sound_645_4'};
    
    for nsound = [0 nsemi]
        
        WavName                                     = ['Stimuli/' list_wavfiles{nsound+1} '.wav'];
        [tmpWav,toneFs]                             = audioread(WavName);  % load sound file
        AllSoundWav                                 = cat(3,AllSoundWav,tmpWav);
        AllSoundName{end+1}                         = WavName;
        clear tmpWav WavName
        
    end
    
    step_size                                       = 2.5;
    start_threshold                                 = 50;
    
    far_end                                         = 200;
    start_thresh                                    = [-far_end:step_size:50 start_threshold+step_size:step_size:far_end];
    
    for ntype = 1:2
        for xi = 1:length(start_thresh)
            
            Target1play                             = squeeze(AllSoundWav(:,:,ntype));
            Target1playNoise                        = awgn(Target1play,start_thresh(xi),'measured');
            
            AllSounds{nsemi}{ntype}{xi,1}           = Target1playNoise;
            AllSounds{nsemi}{ntype}{xi,2}           = start_thresh(xi);
            
            clear Target1play Target1playNoise
            
        end
    end
    
end