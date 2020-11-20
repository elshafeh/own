clear ; clc ;

suj_list    = [1:4 8:17];
RT_median   = zeros(14,3);

for a = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(a))];
    
    behav_in_recoded       = load(['/Volumes/PAT_MEG2/Fieldtripping/data/pos/' suj '.pat2.fin.pos']);
    behav_in_recoded       = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
    
    
    for n = 1:length(behav_in_recoded)
        
        if  floor(behav_in_recoded(n,2)/1000)==1
            
            code    =   behav_in_recoded(n,2)-1000;
            CUE     =   floor(code/100);
            DIS     =   floor((code-100*CUE)/10);
            
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
    
    clearvars -except ntrl a suj_list RT_median
    
    for n = 1:3
        RT_median(a,n) = median(ntrl{n});
    end
    
    clearvars -except a suj_list RT_median
    
end