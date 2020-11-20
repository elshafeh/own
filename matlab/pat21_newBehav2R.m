clear; clc ;

rt_tot= zeros(14,4,4);

hndl    = 'meanRT';
fOUT    = ['../txt/PrepAtt2.new.' hndl '.txt'];
fid     = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','CUE','DIS',hndl);

suj_list = [1:4 8:17];

for sb = 1:14
    
    for c_cue = 1:4
        for c_dis = 1:4
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
    pos(:,7)            =   mod(pos(:,4),10);
    
    cue_cnd = {'NL','NR','L','R'};
    
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
            
            ccue    = pos(n,5);
            cdis    = pos(n,6)+1;
            ctar    = pos(n,7);
            
            if ccue == 0
                
                if mod(ctar,2) ~= 0
                    
                    new_ccue = 1;
                    
                else
                    new_ccue = 2;
                    
                end
                
            elseif ccue == 1
                
                new_ccue = 3;
                
            elseif ccue == 2
                
                new_ccue = 4;
                
            end
            
            rt_sub{new_ccue,cdis} = [rt_sub{new_ccue,cdis};rt];
            
            clear x y new_ccue ccue cdis ctar rt
            
        end
        
    end
    
    for c_cue = 1:4
        for c_dis = 1:4
            %             rt_tot(sb,c_cue,c_dis) = median(rt_sub{c_cue,c_dis});
            rt_tot(sb,c_cue,c_dis) = mean(rt_sub{c_cue,c_dis});
        end
    end
    
end

for sb = 1:14
    for c_cue = 1:4
        for c_dis = 1:4
            suj = ['yc' num2str(sb)];
            fprintf(fid,'%s\t%s\t%s\t%.2f\n',suj,cue_cnd{c_cue},['D' num2str(c_dis-1)],rt_tot(sb,c_cue,c_dis));
        end
    end
end

fclose(fid);

clearvars -except rt_tot

pow          = squeeze(mean(rt_tot,1));
sem          = squeeze(std(rt_tot,1)) / sqrt(14);

cue_cnd = {'NL','NR','L','R'};

figure;
hold on;
for n = 1:4
    errorbar(pow(n,:),sem(n,:),'LineWidth',1)
    set(gca,'Xtick',0:4,'XTickLabel', {'','DIS0','DIS1','DIS2','DIS3',''});
    set(gca,'fontsize',18)
    set(gca,'FontWeight','bold');
    ylim([300 850])
end
legend(cue_cnd)

figure;
dis0 = [pow(1,1) pow(2,1) pow(3,1) pow(4,1)];
sem0 = [sem(1,1) sem(2,1) sem(3,1) sem(4,1)];
errorbar(dis0,sem0,'LineWidth',1)
set(gca,'Xtick',0:4,'XTickLabel', {'','NL','NR','L','R',''});
ylim([300 850])

figure;
boxplot(squeeze(rt_tot(:,:,1)),'labels',cue_cnd);
ylim([300 850])

mean_nl = squeeze(rt_tot(:,1,1));
mean_nr = squeeze(rt_tot(:,2,1));
mean_l  = squeeze(rt_tot(:,3,1));
mean_r  = squeeze(rt_tot(:,4,1));

perm1 = permutation_test([mean_r mean_l],10000);
perm2 = permutation_test([mean_r mean_nr],10000);
perm3 = permutation_test([mean_r mean_nl],10000);
perm4 = permutation_test([mean_l mean_nr],10000);
perm5 = permutation_test([mean_l mean_nl],10000);
perm6 = permutation_test([mean_nr mean_nl],10000);
