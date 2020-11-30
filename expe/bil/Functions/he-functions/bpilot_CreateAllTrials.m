function bloc_structure = bpilot_CreateAllTrials(ColIdx)

global Info

possibStim          = {[1 1],[1 2],[2 1],[2 2]}; % orien then freq (1 and 2 for each category)
possibMask          = Info.targetcontrast; % either 1 (easy) or 0.4 (hard)
possibDur           = 0.1333;

% for info
% 1frame    6frame    7frame 8frame 9frame
% [0.0167    0.1000    0.1167 0.1333]

StimDeg             = [135;45]; %[107;73]; % 
StimCyc             = [0.2;0.6]; %

StimCol             = ColIdx;
possibMatch         = [1 0]; % {'yes','no'};

bloc_structure     = [];

for ncolor = 1:length(StimCol)
    
    trial_idx       = 0;
    
    for ncuetype = 1:2
        for nfeat = 1:2
            for ntar = 1:4
                for nprob = 1:4
                    
                    % this loops through all possible target types
                    
                    for ntar_ori = 1:size(StimDeg,2)
                        for ntar_frq  = 1:size(StimCyc,2)
                            for nprob_ori = 1:size(StimDeg,2)
                                for nprob_frq = 1:size(StimCyc,2)
                                    
                                    trial_idx                                       = trial_idx + 1;
                                    
                                    target_type                                     = possibStim{ntar};
                                    probe_type                                      = possibStim{nprob};
                                    
                                    trial_structure(trial_idx).target               = [StimDeg(target_type(1),ntar_ori) StimCyc(target_type(2),ntar_frq)];
                                    trial_structure(trial_idx).probe                = [StimDeg(probe_type(1),nprob_ori) StimCyc(probe_type(2),nprob_frq)];
                                    
                                    trial_structure(trial_idx).match                = possibMatch(length(unique([target_type(nfeat) probe_type(nfeat)])));
                                    
                                    trial_structure(trial_idx).task                 = nfeat;
                                    trial_structure(trial_idx).cue                  = ncuetype;
                                    
                                    trial_structure(trial_idx).DurTar               = possibDur;
                                    trial_structure(trial_idx).MaskCon              = possibMask;
                                    trial_structure(trial_idx).DurCue               = 0.3; % fixed
                                    
                                    trial_structure(trial_idx).color                = StimCol(ncolor);
                                    trial_structure(trial_idx).nbloc                = ncolor;
                                    
                                    trial_structure(trial_idx).PresTarg             = [];
                                    trial_structure(trial_idx).PresProb             = [];
                                    trial_structure(trial_idx).PresMask             = [];
                                    trial_structure(trial_idx).repRT                = [];
                                    trial_structure(trial_idx).repButton            = [];
                                    trial_structure(trial_idx).repCorrect           = [];
                                    
                                    trial_structure(trial_idx).nmbr                 = trial_idx;
                                    
                                    trial_structure(trial_idx).tarClass             = ['Class' num2str(ntar)];
                                    trial_structure(trial_idx).proClass             = ['Class' num2str(nprob)];
                                    
                                    trial_structure(trial_idx).trigtime             = [];
                                    
                                end
                                
                            end
                        end
                    end
                end
                
            end
        end
    end
    
    bloc_structure          = [bloc_structure trial_structure(Shuffle(1:length(trial_structure)))];
    
end

clearvars -except bloc_structure

bloc_structure              = struct2table(bloc_structure);