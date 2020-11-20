clear ; clc ;

for list_chan = {'aud_L','aud_R'}
    for list_cue = {'RCnD','CnD','LCnD'}
        for list_time = {'m1000m200','p200p1000'}
            
            load(['../data/mg1/field/mg1.' list_cue{:} '.broadAreas.' list_time{:} '.' list_chan{:} '.PLV.PAC.mat']) ; old_pac = seymour_pac ; clear seymour_pac
            load(['../data/mg1/field/mg1.' list_cue{:} '.broadAreas.' list_time{:} '.' list_chan{:} '.PLV.optimisedPAC.mat']) ; new_pac = seymour_pac ; clear seymour_pac
            
            check = old_pac.mpac - new_pac.mpac ;
            check = unique(check);
            
            if length(check) > 1
                fprintf('oops !')
            end
            
        end
    end
end