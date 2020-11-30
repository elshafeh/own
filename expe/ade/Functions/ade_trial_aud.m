function Target1playNoise = ade_trial_aud(P, TrialSide,TrialType,currentThresh,TargetCode)

% This plays one trial of auditory staircase
% inputs are:
% TrialSide : ear of sound to be played 
% TrialType: low-then-high target or high-then-low target
% currentThresh: SNR level
% -- % choose order of beep presentation % -- %

if TargetCode == 77
    
    % this was amde to avoid a weird crash in the system if all sounds were
    % played one by one .. 
    
    snd_cnct                = [];
    
    for inoise = 1:2
       
        list_noise                      = [50 currentThresh];
        
        ix_tar                          = [P.AllSoundWav{TrialType}{:,2}];
        
        find_tar                        = find(round(ix_tar,1) == round(list_noise(inoise),1));
        
        Target1playNoise                = P.AllSoundWav{TrialType}{find_tar,1};
        Target1playNoise                = Target1playNoise* P.VolumeCutoff; % this has been added to adjust volume once noise has been added
        
        tblank                          = zeros(size(Target1playNoise,1)*30,2);
        snd_cnct                        = [snd_cnct;Target1playNoise;tblank];
        
    end
    
else
    
    ix_tar                              = [P.AllSoundWav{TrialType}{:,2}];
    
    find_tar                            = find(round(ix_tar,1) == round(currentThresh,1));
    
    Target1playNoise                    = P.AllSoundWav{TrialType}{find_tar,1};
    Target1playNoise                    = Target1playNoise * P.VolumeCutoff; % this has been added to adjust volume once noise has been added
    
end

% -- % choose side of beep presentation % -- %
% Originally 1 for right and 2 for left so I'm reversing them to match the visual :)
% (3) plays it in both ears
if TargetCode == 77
    Target1playNoise                     = snd_cnct;
end

new_side                                = [2 1];

if TrialSide < 3
    Target1playNoise(:,new_side(TrialSide)) = 0;
end

ade_playsound(Target1playNoise',P,TargetCode);