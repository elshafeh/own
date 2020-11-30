function rand_vector = ade_CreateRandTrials(P)

if strcmp(P.experiment,'stair')
    
    [rand_vector]   = ade_nw_create_trials_for_stair(P)
    
else
    
    if strcmp(P.runtype,'run')
        [rand_vector] = ade_nw_create_trials_for_expe(P);
    else
        [rand_vector] = ade_nw_create_trials_for_train(P);
    end
    
end
