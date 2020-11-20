function posOUT = PrepAtt22_funk_exclude_entire_trial(behav_in_recoded)

behav_in_recoded = [behav_in_recoded(:,3) behav_in_recoded(:,3) behav_in_recoded(:,2) behav_in_recoded(:,1)];
posOUT           = [];

for n = 1:length(behav_in_recoded)
    
    if  floor(behav_in_recoded(n,3)/1000)==1
        fcue=1; p=1;
        
        while fcue==1 && n+p <=length(behav_in_recoded)
            
            acc_width = behav_in_recoded(n+p,4) - behav_in_recoded(n,4);
            acc_width = acc_width * 5/3;
            
            if floor(behav_in_recoded(n+p,3)/1000)~=1 && (behav_in_recoded(n+p,4) > behav_in_recoded(n+p-1,4)) && acc_width <= 5000
                p=p+1;
            else
                fcue=2;
            end
            
            
        end
        
        p               = p-1;
        trl             = [behav_in_recoded(n:n+p,4) behav_in_recoded(n:n+p,3) behav_in_recoded(n:n+p,2)];
        
        xi = trl(trl(:,3)~=0,3);
        xi = sort(unique(xi));        
        
        if ~isempty(xi)
            trl(:,3) = xi(1);
        end
        
        posOUT = [posOUT;trl] ; clear trl ;
        
        
    end
    
end
