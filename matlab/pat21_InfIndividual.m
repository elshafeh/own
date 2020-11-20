clear ; clc ;

suj_list    = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(a))];
    
    behav_in_recoded       = load(['../pos/' suj '.pat2.newrec.behav.pos']);
    behav_in_recoded       = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
    
    ntrl{1} = [];
    ntrl{2} = [];
    
    for n = 1:length(behav_in_recoded)
        
        if  floor(behav_in_recoded(n,2)/1000)==1
            
            code    =   behav_in_recoded(n,2)-1000;
            CUE     =   floor(code/100);
            DIS     =   floor((code-100*CUE)/10);
            
            if CUE ~= 0
                CUE = 1;
            end
            
            if DIS == 0
                
                fcue=1; p=1;
                
                while fcue==1 && n+p <=length(behav_in_recoded)
                    
                    if floor(behav_in_recoded(n+p,2)/1000)~=1
                        p=p+1;
                    else
                        fcue=2;
                    end
                    
                    
                end
                
                p=p-1;
                
                trl=behav_in_recoded(n:n+p,:);
                
                tartmp          = find(floor(trl(:,2)/1000)==3);
                reptmp          = find(floor(trl(:,2)/1000)==9);
                
                ntrl{CUE+1}     = [ntrl{CUE+1};(trl(reptmp(1),1)-trl(tartmp,1)) * 5/3];
                
            end
            
        end
        
    end
    
    inf_diff(a,1) = median(ntrl{1});
    inf_diff(a,2) = median(ntrl{2});

    [h,p_val(a)] = ttest(ntrl{1},ntrl{2}(1:length(ntrl{1})));
    
end

clearvars -except p_val

% dff = inf_diff(:,1) - inf_diff(:,2);