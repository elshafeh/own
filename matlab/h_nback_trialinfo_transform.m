function new_trialinfo = h_nback_trialinfo_transform(trialinfo)

new_trialinfo                           = [];

for nt = 1:length(trialinfo)
    
    % find first stimulus
    if trialinfo(nt,2) == 1
        
        nback_cond                      = trialinfo(nt,1);
        trl                             = [];
        
        switch nback_cond
            case 5 %1back
                
                if nt < length(trialinfo) && trialinfo(nt+1,2) == 2
                    trl                 = trialinfo(nt:nt+1,:);
                end
                
            case 6 %2back
                
                if nt < length(trialinfo)-1 && trialinfo(nt+1,2) == 3 && trialinfo(nt+2,2) == 2
                    trl                 = trialinfo(nt:nt+2,:);
                end
                
        end
        
        if ~isempty(trl)
            
            % get rt
            trial_rt                        = trl(trl(:,2) == 2,5);
            trial_correct                   = trl(trl(:,2) == 2,4);
            
            % find incorrect responses
            find_incorrect                  = find(trl(:,4) == 2 | trl(:,4) == 4);
            
            trl(:,4)                        = trial_correct;
            trl(:,5)                        = trial_rt;
            new_trialinfo                   = [new_trialinfo; trl]; clear trl;
            
        end
        
    end
end