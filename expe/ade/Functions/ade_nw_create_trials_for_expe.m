function [rand_vector] = ade_nw_create_trials_for_expe(P)

% 1 for left hemispace and 2 right hemispace
% 1 for ascending tone-pair/left tilted gabor & 2 for descending tone-pair/right tilted gabor
% 1 For first RMapping and 2 for second RMapping
% 0 for noise-free 1 for noisey

rand_vector.side    = NaN(P.nBlock,max(P.nTrials));
rand_vector.type    = NaN(P.nBlock,max(P.nTrials));
rand_vector.inst    = NaN(P.nBlock,max(P.nTrials));
rand_vector.nois    = NaN(P.nBlock,max(P.nTrials));

    
ix                  = 0;

for nblock = 1:P.nBlock
    
    tot_trials          = P.nTrials(P.nBlock);
    trial_structure     = nan(tot_trials,4);
    
    fct                 = tot_trials/8;
    
    for nf = 1:fct
        
        for stim_side = 1:2
            for stim_type = 1:2
                for stim_inst = 1:2
                    
                    ix = ix + 1;
                    trial_structure(ix,1) = stim_side;
                    trial_structure(ix,2) = stim_type;
                    trial_structure(ix,3) = stim_inst;
                    
                    if nf < 3
                        trial_structure(ix,4) = 0; % noise-free;
                    else
                        trial_structure(ix,4) = 1; %noise
                    end
                    
                end
            end
        end
    end
    
    rand_order                      = Shuffle(1:length(trial_structure));
    
    rand_vector.side(nblock,:)      = trial_structure(rand_order,1);
    rand_vector.type(nblock,:)      = trial_structure(rand_order,2);
    rand_vector.inst(nblock,:)      = trial_structure(rand_order,3);
    rand_vector.nois(nblock,:)      = trial_structure(rand_order,4);
    
end