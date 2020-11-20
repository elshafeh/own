clear; clc ;

ttest_result = [];

suj_list = [1:4 8:17];

for sb = 1:14
    
    for c_cue = 1:4
        %         for c_dis = 1:4
            rt_sub{c_cue} = [];
            %         end
    end
    
    suj = ['yc' num2str(suj_list(sb))];
    
    pos                 =   load(['../data/pos/' suj '.pat2.newrec.behav.pos']);
    pos                 =   pos(pos(:,3) == 0,1:2);
    pos(:,3)            =   floor(pos(:,2)/1000);
    pos(:,4)            =   pos(:,2) - (pos(:,3)*1000);
    pos(:,5)            =   floor(pos(:,4)/100);
    pos(:,6)            =   floor((pos(:,4)-100*pos(:,5))/10);     % Determine the DIS latency
    pos(:,7)            =   pos(:,4) - ((pos(:,5)*100) + (pos(:,6)*10));
    %     pos(pos(:,5) > 0,5) =   1;
    
    cue_cnd = {'NL','NR','L','R'};
    
    for n = 1:length(pos)
        
        if  pos(n,3) == 1 && pos(n,6) == 0
            
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
            
            rt_sub{new_ccue} = [rt_sub{new_ccue};rt];
            
            clear x y new_ccue ccue cdis ctar rt
            
        end
        
    end
    
    x = length(rt_sub{1});
    y = length(rt_sub{2});
    z = min([x y]);
    
    trl_array_nl = PrepAtt2_fun_create_rand_array(1:x,z);
    trl_array_nr = PrepAtt2_fun_create_rand_array(1:y,z);
    
    nl = rt_sub{1}(trl_array_nl);
    nr = rt_sub{2}(trl_array_nr);
    
    %     p_val = permutation_test([nl nr],10000);
    %
    %     subplot(2,7,sb)
    %     boxplot([nl nr])
    %     title(num2str(p_val))
    %     ylim([200 3000])
    
    %         [h,p_val] = ttest(nl,nr);
    
    ttest_result(sb,1) = abs(x-y);
    [h,ttest_result(sb,2)] = ttest(nl,nr);clear p_val nl nr x y z
    
    %     for nn = 1:4
    %         rt_tot(sb,nn) = median(rt_sub{nn});
    %     end
    
    clearvars -except ttest_result suj_list sb rt_tot
    
end

% mean_nl = squeeze(rt_tot(:,1,1));
% mean_nr = squeeze(rt_tot(:,2,1));
% mean_l  = squeeze(rt_tot(:,3,1));
% mean_r  = squeeze(rt_tot(:,4,1));
% 
% perm1 = permutation_test([mean_nl mean_nr],10000);
% perm2 = permutation_test([mean_nl mean_l],10000);
% perm3 = permutation_test([mean_nl mean_r],10000);
% perm4 = permutation_test([mean_nr mean_l],10000);
% perm5 = permutation_test([mean_nr mean_r],10000);
% perm6 = permutation_test([mean_r mean_l],10000);
% 
% pow          = mean(rt_tot,1);
% sem          = std(rt_tot,1) / sqrt(length(mean_nl));
% 
% figure;
% errorbar(pow,sem,'LineWidth',1)
% set(gca,'Xtick',0:4,'XTickLabel', {'','NL','NR','L','R',''});
% ylim([450 650])