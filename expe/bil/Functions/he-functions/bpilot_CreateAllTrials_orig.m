function bloc_structure = bpilot_CreateAllTrials

possibStim      = {[1 1],[1 2],[2 1],[2 2]}; % orien then freq (1 and 2 for each category)
possibMask      = [0.25 0.35 0.4 0.45 0.55];
possibDur       = repmat(0.1,length(possibMask));

xu              = 64 * length(possibDur); % total number for all combinations (we;re not randomizing color)

StimDeg1        = [144 107];
StimDeg2        = [36 73];
StimCyc1        = [0.2 0.25];
StimCyc2        = [0.6 0.65];

possibOriTarg   = [Shuffle(repmat(StimDeg1,1,xu/2));Shuffle(repmat(StimDeg2,1,xu/2))];
possibFreqTarg  = [Shuffle(repmat(StimCyc1,1,xu/2));Shuffle(repmat(StimCyc2,1,xu/2))];

possibOriProb   = [Shuffle(repmat(StimDeg1,1,xu/2));Shuffle(repmat(StimDeg2,1,xu/2))];
possibFreqProb  = [Shuffle(repmat(StimCyc1,1,xu/2));Shuffle(repmat(StimCyc2,1,xu/2))];

possibColor     = Shuffle(repmat([1 2],1,xu/2)); % color is nt beong fully randomized ;)
possibMatch     = [1 0]; % {'yes','no'};

trial_idx       = 0;
trialBookeep    = [];

for ntiming = 1:length(possibDur)
    for ncuetype = 1:2
        for nfeat = 1:2
            for ntar = 1:4
                for nprob = 1:4
                    
                    trial_idx                                       = trial_idx + 1;
                    
                    target_type                                     = possibStim{ntar};
                    probe_type                                      = possibStim{nprob};
                    
                    trial_structure(trial_idx).target               = [possibOriTarg(target_type(1),trial_idx) possibFreqTarg(target_type(2),trial_idx)];
                    trial_structure(trial_idx).probe                = [possibOriProb(probe_type(1),trial_idx) possibFreqProb(probe_type(2),trial_idx)];
                    
                    trial_structure(trial_idx).match                = possibMatch(length(unique([target_type(nfeat) probe_type(nfeat)])));
                    
                    trial_structure(trial_idx).task                 = nfeat;
                    trial_structure(trial_idx).cue                  = ncuetype;
                    
                    trial_structure(trial_idx).DurTar               = possibDur(ntiming);
                    trial_structure(trial_idx).MaskCon              = possibMask(ntiming);
                    trial_structure(trial_idx).DurCue               = 0.3;
                    
                    trial_structure(trial_idx).color                = possibColor(trial_idx); % possibCol(ncolor);
                    
                    trial_structure(trial_idx).PresTarg             = [];
                    trial_structure(trial_idx).PresProb             = [];
                    trial_structure(trial_idx).PresMask             = [];
                    trial_structure(trial_idx).repRT                = [];
                    trial_structure(trial_idx).repButton            = [];
                    trial_structure(trial_idx).repCorrect           = [];
                    
                    trial_structure(trial_idx).nmbr                 = trial_idx;
                    
                    trial_structure(trial_idx).tarClass             = ['Class' num2str(ntar)];
                    trial_structure(trial_idx).proClass             = ['Class' num2str(nprob)];
                    
                    trialBookeep                                    = [trialBookeep;ntiming ncuetype nfeat trial_structure(trial_idx).match target_type];
                    
                end
            end
        end
    end
end

clearvars -except trial_structure trialBookeep

totblocks                                           = length(trial_structure)/64;

cnstnt                                              = length(trial_structure)/totblocks;
rnd_vect                                            = [];

i1                                                  = ones(1,totblocks,1);
i2                                                  = repmat(cnstnt,totblocks,1);

for nb = 1:totblocks
    
    tmp                                             = Shuffle(i1:i2);
    rnd_vect                                        = [rnd_vect tmp]; clear tmp;
    
    i1                                              = i1+cnstnt;
    i2                                              = i2+cnstnt;
    
end

clearvars -except rnd_vect trial_structure

bloc_structure                                      = trial_structure(rnd_vect);
bloc_structure                                      = struct2table(bloc_structure);