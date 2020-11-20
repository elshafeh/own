clear;clc;

suj_list = {'s1' 's22','s35','s10','s23','s36','s11','s24','s37','s12','s25','s38','s13','s26','s39' ,...
    's14','s27','s4','s15','s28','s40','s16','s29','s41','s17','s3','s5' ...
    ,'s18','s30','s6','s19','s31','s7','s2','s32','s8','s20','s33','s9','s21','s34'};

i = 0 ;

for a = 1:length(suj_list)
    
    suj                         = suj_list{a};
    chk                         = dir(['../data/pos/' suj '.pat.rec.pos']);
    
    if length(chk) ==1 && ~strcmp(suj,'s5')
        
        i = i + 1;
        
        behav_in_recoded            = load(['../data/pos/' suj '.pat.rec.pos']);
        behav_in_recoded            = behav_in_recoded(behav_in_recoded(:,3)==0,:);

        ntrl{1}                     = [];
        ntrl{2}                     = [];
        ntrl{3}                     = [];
        ntrl{4}                     = [];
        
        for n = 1:length(behav_in_recoded)
            if  floor(behav_in_recoded(n,2)/1000)==1
                
                code            =   behav_in_recoded(n,2)-1000;
                code_CUE        =   floor(code/100);
                code_DIS        =   floor((code-100*code_CUE)/10);
                code_TAR        =   rem(code,10);
                
                if code_DIS == 0
                    
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
                    reptmp          = find(trl(:,2) ==1);
                    
                    if code_CUE == 0
                        where2put       = code_TAR;
                    else 
                        where2put       = code_CUE+2;
                    end
                    
                    if length(reptmp) == 1
                        if reptmp>tartmp
                            
                            RT                  = (trl(reptmp(1),1)-trl(tartmp,1)) * 5/3;
                            
                            if RT >= 200
                                ntrl{where2put}     = [ntrl{where2put};RT];
                            end
                            
                        end
                    end
                    
                end
            end
            
        end
    end
    
    x = length(ntrl{1});
    y = length(ntrl{2});
    z = min([x y]);
    
    trl_array_nl = PrepAtt2_fun_create_rand_array(1:x,z);
    trl_array_nr = PrepAtt2_fun_create_rand_array(1:y,z);
    
    nl = ntrl{1}(trl_array_nl);
    nr = ntrl{2}(trl_array_nr);
    
    %     p_val = permutation_test([nl nr],10000);
    %
    %     subplot(2,7,sb)
    %     boxplot([nl nr])
    %     title(num2str(p_val))
    %     ylim([200 3000])
    
    %         [h,p_val] = ttest(nl,nr);
    
    %     ttest_result(i,1)      = abs(x-y);
    [h,ttest_result(i,1)]  = ttest(nl,nr);clear p_val nl nr x y z
    
    %     for nn = 1:4
    %         rt_tot(i,nn) = median(ntrl{nn});
    %     end
    
end

clearvars -except rt_tot ttest_result

ttest_result = sort(ttest_result);

% mean_nl = squeeze(rt_tot(:,1));
% mean_nr = squeeze(rt_tot(:,2));
% mean_l  = squeeze(rt_tot(:,3));
% mean_r  = squeeze(rt_tot(:,4));
%
% perm1 = permutation_test([mean_nl mean_nr],10000);
% perm2 = permutation_test([mean_nl mean_l],10000);
% perm3 = permutation_test([mean_nl mean_r],10000);
% perm4 = permutation_test([mean_nr mean_l],10000);
% perm5 = permutation_test([mean_nr mean_r],10000);
% perm6 = permutation_test([mean_r mean_l],10000);
%
% % [h_perm1 , p_perm1] = ttest(mean_nl,mean_nr);
% % [h_perm2 , p_perm2]= ttest(mean_nl,mean_l);
% % [h_perm3 , p_perm3]= ttest(mean_nl,mean_r);
% % [h_perm4 , p_perm4]= ttest(mean_nr,mean_l);
% % [h_perm5 , p_perm5]= ttest(mean_nr,mean_r);
% % [h_perm6 , p_perm6]= ttest(mean_r,mean_l);
%
% pow          = mean(rt_tot,1);
% sem          = std(rt_tot,1) / sqrt(length(mean_nl));
%
% figure;
% errorbar(pow,sem,'LineWidth',1)
% set(gca,'Xtick',0:4,'XTickLabel', {'','NL','NR','L','R',''});
% ylim([300 450])