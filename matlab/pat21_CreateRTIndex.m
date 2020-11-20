clear ; clc ;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                    = ['yc' num2str(suj_list(sb))];
    behav_in_recoded       = load(['/Volumes/PAT_MEG2/Fieldtripping/data/pos/' suj '.pat2.fin.pos']);
    behav_in_recoded       = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
    
    ntrl_summary = [];
    
    for n = 1:length(behav_in_recoded)
        
        if  floor(behav_in_recoded(n,2)/1000)==1

            code    =   behav_in_recoded(n,2)-1000;
            CUE     =   floor(code/100);
            DIS     =   floor((code-100*CUE)/10);
            
            fcue=1; p=1;
            
            while fcue==1 && n+p <=length(behav_in_recoded)
                
                if floor(behav_in_recoded(n+p,2)/1000)~=1
                    p=p+1;
                else
                    fcue=2;
                end
                
                
            end
            
            p=p-1;
            
            trl     = behav_in_recoded(n:n+p,:);
            
            tartmp  = find(floor(trl(:,2)/1000)==3);
            reptmp  = find(floor(trl(:,2)/1000)==9);
            rt      = (trl(reptmp(1),1)-trl(tartmp,1)) * 5/3;
            
            ntrl_summary = [ntrl_summary; CUE DIS rt];
            
        end
    end
    
    for d = 1:3        
        rt_dis{sb,d} = ntrl_summary(ntrl_summary(:,2) == d,3); 
        rt_index{sb,d} = find(ntrl_summary(:,2) == d);
    end
    
end

clearvars -except rt_dis rt_index ;

save ../data/yctot/rt/rt_dis_per_delay.mat ;