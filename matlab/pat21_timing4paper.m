clear ; clc ;

cueOnset  = [];

for sb = 1:14
    
    suj_list            = [1:4 8:17];
    suj                 = ['yc' num2str(suj_list(sb))];
    behav_in_recoded    = load(['../data/pos/' suj '.pat2.newrec.pos']);
    
    tmp(:,3) = behav_in_recoded(:,2);
    tmp(:,4) = behav_in_recoded(:,1);
    
    behav_in_recoded = tmp; clear tmp ;
    
    for n = 1:length(behav_in_recoded)
        
        if  floor(behav_in_recoded(n,3)/1000)==1
            
            code =  behav_in_recoded(n,3)-1000;
            CUE  =  floor(code/100);
            DIS  =  floor((code-100*CUE)/10);
            TAR  =  mod(code,10);
            
            fcue=1; p=1;
            
            cnsnt = 5/3 ;
            
            while fcue==1 && n+p <=length(behav_in_recoded)
                
                if floor(behav_in_recoded(n+p,3)/1000)~=1
                    p=p+1;
                else
                    fcue=2;
                end
                
            end
            
            trl = behav_in_recoded(n:n+p-1,:);
            
            cuetmp = find (floor(trl(:,3)/1000)==1);
            tartmp = find (floor(trl(:,3)/1000)==3);
            distmp = find (floor(trl(:,3)/1000)==2);
            reptmp = find (floor(trl(:,3)/1000)==9);
            
            cueON = trl(cuetmp,4);
            tarON = trl(tartmp,4);
            
            cueOnset = [cueOnset; cueON];
            
        end
        
    end
    
end

clearvars -except cueOnset;

trl_length = [];

for n = 2:60
    trl_length(n-1,1) = (cueOnset(n+1) - cueOnset(n)) * 5/3 ;
end