clear; clc ;

hndl = 'medianRT';
fOUT = ['../txt/PrepAtt2.' hndl '.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','CUE','DIS',hndl);

for sb = 1:4
    for c_cue = 1:3
        for c_dis = 1:4
            rt_tot(sb,c_cue,c_dis) = 0;
        end
    end
end

suj_list = [1:4 8:17];

for sb = 1:14
    
    for c_cue = 1:3
        for c_dis = 1:4
            rt_sub{c_cue,c_dis} = [];
        end
    end
    
    suj = ['yc' num2str(suj_list(sb))];
    
    pos                 =   load(['../pos/' suj '.pat2.newrec.behav.pos']);
    pos                 =   pos(pos(:,3) == 0,1:2);
    pos(:,3)            =   floor(pos(:,2)/1000);
    pos(:,4)            =   pos(:,2) - (pos(:,3)*1000);
    pos(:,5)            =   floor(pos(:,4)/100);
    pos(:,6)            =   floor((pos(:,4)-100*pos(:,5))/10);     % Determine the DIS latency
    %     pos(pos(:,5) > 0,5) =   1;
    
    
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
        for c_dis = 1:4
            rt_tot(sb,c_cue,c_dis) = median(rt_sub{c_cue,c_dis});
        end
    end
    
end

% pow          = rt_tot(:,:,2:4);
% pow          = squeeze(mean(pow,3));
%
% % pow          = rt_tot(:,1:3,2:4);
% % pow          = squeeze(mean(pow,2));
% rt           = mean(pow,1);
% sem          = std(pow) / sqrt(14) ;
%
% errorbar(rt,sem,'k','LineWidth',1)
% % set(gca,'Xtick',0:4,'XTickLabel', {'','DIS1','DIS2','DIS3',''});
% set(gca,'Xtick',0:4,'XTickLabel', {'','NCue','LCue','RCue',''});
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold');
% % ylim([400 650])

for sb = 1:14
    for c_cue = 1:3
        for c_dis = 1:4
            
            suj = ['yc' num2str(sb)];
            fprintf(fid,'%s\t%s\t%s\t%.2f\n',suj,cue_cnd{c_cue},['D' num2str(c_dis-1)],rt_tot(sb,c_cue,c_dis));
            
            
        end
    end
end
fclose(fid);