clear ; clc ;

suj_list = [1:4 8:17];

for sb = 1:14
    
    for c_cue = 1:3
        for c_dis = 1
            rt_sub{c_cue,c_dis} = [];
        end
    end
    
    suj = ['yc' num2str(suj_list(sb))];
    
    pos                 =   load(['../data/pos/' suj '.pat2.newrec.behav.pos']);
    pos                 =   pos(pos(:,3) == 0,1:2);
    pos(:,3)            =   floor(pos(:,2)/1000);
    pos(:,4)            =   pos(:,2) - (pos(:,3)*1000);
    pos(:,5)            =   floor(pos(:,4)/100);
    pos(:,6)            =   floor((pos(:,4)-100*pos(:,5))/10);     % Determine the DIS latency
    pos                 =   pos(pos(:,6) ==0,:);
    
    cue_cnd = {'N','L','R'};
    
    for n = 1:length(pos)
        
        if  pos(n,3) == 1
            
            fcue=1; p=1;
            
            while fcue==1 && n+p <=length(pos)
                
                if floor(pos(n+p,3))~=1
                    p=p+1;
                else
                    fcue=2;
                end
                
            end
            
            p=p-1;
            
            trl=pos(n:n+p,:);
            
            tartmp  = find(floor(trl(:,3))==3);
            reptmp  = find(floor(trl(:,3))==9);
            
            rt      = (trl(reptmp,1) - trl(tartmp,1)) * 5/3 ;
            
            ccue    = pos(n,5)+1;
            cdis    = pos(n,6)+1;
            
            rt_sub{ccue,cdis} = [rt_sub{ccue,cdis};rt];
            
            clear x y
            
        end
        
    end
    
    for c_cue = 1:3
        for c_dis = 1
            rt_tot(sb,c_cue,c_dis) = median(rt_sub{c_cue,c_dis});
        end
    end
    
end

clearvars -except rt_tot ;

rt           = mean(rt_tot,1);
sem          = std(rt_tot) / sqrt(14) ;

errorbar(rt,sem,'k','LineWidth',1)
set(gca,'Xtick',0:4,'XTickLabel', {'','NCue','LCue','RCue',''});
ylim([450 650])