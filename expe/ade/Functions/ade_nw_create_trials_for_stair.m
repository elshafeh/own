function [rand_vector]   = ade_nw_create_trials_for_stair(P)

for nblock = 1:P.nBlock
    
    tot_trials                          = P.nTrials(P.nBlock);
    trial_structure                     = nan(tot_trials,4);
    
    for stim_side = 1:2
        
        ix                              = stim_side:2:tot_trials;
        trial_structure(ix,1)           = stim_side;
        
        for stim_type = 1:2
            
            sub_trials                  = find(trial_structure(:,1) == stim_side);
            ix                          = sub_trials(stim_type:2:length(sub_trials));
            trial_structure(ix,2)       = stim_type;
            
            for stim_inst = 1:2
                
                sub_trials              = find(trial_structure(:,1) == stim_side & trial_structure(:,2) == stim_type);
                ix                      = sub_trials(stim_inst:2:length(sub_trials));
                trial_structure(ix,3)   = stim_inst;
                
                sub_trials              = find(trial_structure(:,1) == stim_side & trial_structure(:,2) == stim_type & trial_structure(:,3) == stim_inst);
                ix                      = sub_trials(1);
                trial_structure(ix,4)   = 0; % noise-free
                
                ix                      = sub_trials(2:end);
                trial_structure(ix,4)   = 1; % noisey
                
            end
        end
    end
    
    rand_order                      = Shuffle(1:length(trial_structure));
    
    rand_vector.side(nblock,:)      = trial_structure(rand_order,1);
    rand_vector.type(nblock,:)      = trial_structure(rand_order,2);
    rand_vector.inst(nblock,:)      = trial_structure(rand_order,3);
    rand_vector.nois(nblock,:)      = trial_structure(rand_order,4);
    
    clearvars -except rand_vector nblock P
    
end