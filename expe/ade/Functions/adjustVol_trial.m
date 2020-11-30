function Target1playNoise = adjustVol_trial(P)

for ntype = 1:2
    
    ix_tar                  = [P.AllSoundWav{ntype}{:,2}];
    find_tar                = find(ix_tar == P.StartingThreshold);
    Target1playNoise        = P.AllSoundWav{ntype}{find_tar,1};
    Target1playNoise        = Target1playNoise* P.VolumeCutoff; % this has been added to adjust volume once noise has been added
    
    ade_playsound(Target1playNoise',P,77);
    
    WaitSecs(0.5);
    
end