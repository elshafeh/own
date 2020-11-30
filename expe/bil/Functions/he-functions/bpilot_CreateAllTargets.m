function [TargetStim,ProbeStim,bMask] = bpilot_CreateAllTargets

global Info stim wPtr scr

ix                                              = 0;

bpilot_darkenBackground;
DrawFormattedText(wPtr, 'Preparing the magic ......\n\n please wait :)', 'center', 'center', scr.black);
Screen('Flip', wPtr);

allStim                                         = [[Info.TrialInfo.target];[Info.TrialInfo.probe]];
allOrientation                                  = unique(allStim(:,1));
allFrequency                                    = unique(allStim(:,2));

allContrast                                     = unique([Info.TrialInfo.MaskCon]);

all_freq_mean                                   = [];
all_freq_sd                                     = [];


for n_con = 1:length(allContrast)
    for n_ori = 1:length(allOrientation)
        for n_freq = 1:length(allFrequency)
            
            freqSdConstant                  = 100;
            
            stim.patch.patchcon             = allContrast(n_con);
            
            stim.patch.ori_mean             = allOrientation(n_ori); % CW and CCW relative to vertical
            stim.patch.freq_mean            = allFrequency(n_freq); % in cycles/deg
            stim.patch.freq_sd              = stim.patch.freq_mean / freqSdConstant; %JY: arbitrary
            
            allTarget{n_ori,n_freq}         = genBandpassOrientedGrating(stim.patch);
            
            all_freq_mean                   = [all_freq_mean; stim.patch.freq_mean];
            all_freq_sd                     = [all_freq_sd; stim.patch.freq_sd ] ; %JY: arbitrary
            
        end
    end
end

for nmask = 1:10
    
    tmp                                     = stim.patch;
    tmp.patchcon                            = 1; % this is the parameter to change for mask contrast :)
    
    tmp.freq1_sd                            = all_freq_sd(1);
    tmp.freq1_mean                          = all_freq_mean(1);
    tmp.freq2_sd                            = all_freq_sd(2);
    tmp.freq2_mean                          = all_freq_mean(2);    
    
    allMask{nmask}                          = genBandpassFilteredNoise2freq(tmp);
    
end

for ntrial = 1:height(Info.TrialInfo)
    
    ix                                      = ix+1;
    
    % = % Prepare target , Probe and Mask
    
    where_ori                               = find(allOrientation == Info.TrialInfo(ix,:).target(1));
    where_freq                              = find(allFrequency == Info.TrialInfo(ix,:).target(2));
    
    TargetStim{ntrial}                      = allTarget{where_ori,where_freq};
    
    bMask{ntrial,1}                         = allMask{randi(length(allMask))}; % mask for target
    
    where_ori                               = find(allOrientation == Info.TrialInfo(ix,:).probe(1));
    where_freq                              = find(allFrequency == Info.TrialInfo(ix,:).probe(2));
    
    ProbeStim{ntrial}                       = allTarget{where_ori,where_freq};
    
    bMask{ntrial,2}                         = allMask{randi(length(allMask))}; % mask for probe 
    
end

bpilot_darkenBackground;
DrawFormattedText(wPtr, 'Done!', 'center', 'center', scr.black);
Screen('Flip', wPtr);
WaitSecs(1);