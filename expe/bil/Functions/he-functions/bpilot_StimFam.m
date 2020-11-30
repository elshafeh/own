function bpilot_StimFam

global stim wPtr scr

StimStruc                       = bpilot_CreateAllStim;

for ntar = 1:size(StimStruc,1)
    
    stim.patch.FixColor         = stim.Fix.PossibColor{StimStruc(ntar,:).color};
    
    stim.patch.ori_mean         = StimStruc(ntar,:).target(1); % CW and CCW relative to vertical
    stim.patch.freq_mean        = StimStruc(ntar,:).target(2); % in cycles/deg
    
    stim.patch.freq_sd          = stim.patch.freq_mean/100; %JY: arbitrary
    
    TargetStim                  = genBandpassOrientedGrating(stim.patch);
    
    tmp                         = stim.patch;
    tmp.patchcon                = 2; % this is the parameter to change for mask contrast :)
    bMask                       = genBandpassFilteredNoise(tmp);
    
    degIn                       = StimStruc(ntar,:).target(2);
    
    bpilot_displayStimFam(TargetStim,bMask,degIn);
    
    WaitSecs(0.1);
    
end