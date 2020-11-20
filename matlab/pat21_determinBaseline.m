clear ; clc ;

suj_list    = [1:4 8:17];

i = 0 ;

for a = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(a))];
    
    behav_in_recoded       = load(['../pos/' suj '.pat2.fin.pos']);
    behav_in_recoded       = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
    
    for n = 1:length(behav_in_recoded)
        if  floor(behav_in_recoded(n,2)/1000)==1
            
            code    =   behav_in_recoded(n,2)-1000;
            CUE     =   floor(code/100);
            DIS     =   floor((code-100*CUE)/10);
            
            if DIS ~= 0
                
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
                
                cuetmp          = find(floor(trl(:,2)/1000)==1);
                
                distmp          = find(floor(trl(:,2)/1000)==2);
                
                tartmp          = find(floor(trl(:,2)/1000)==3);
                reptmp          = find(floor(trl(:,2)/1000)==9);
                
                if ~isempty(distmp)
                    i = i +1 ;
                    whenCue{i}         = ((trl(cuetmp,1) - trl(distmp,1)) * 5/3)/1000;
                    whenCueOffset{i}   = ((trl(cuetmp,1) - trl(distmp,1)) * 5/3)/1000 + 0.2;
                    
                    whenTar{i}         = ((trl(tartmp,1) - trl(distmp,1)) * 5/3)/1000;
                    whenRep{i}         = ((trl(reptmp,1) - trl(distmp,1)) * 5/3)/1000;
                end
            end
            
        end
        
    end
    
end

clearvars -except when*

bw = 0.01;

figure;
hold on;
histogram([whenCue{:}],'BinWidth',bw)
histogram([whenCueOffset{:}],'BinWidth',bw)
histogram([whenTar{:}],'BinWidth',bw)
histogram([whenRep{:}],'BinWidth',bw)