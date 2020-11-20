clear ; clc ;

suj_list = [1:4 8:17];

% sub_per = zeros(14,3);

for a = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(a))];
    behav_in_recoded        = load(['../data/pos/' suj '.pat2.newrec.behav.pos']);
    behav_in_recoded        = behav_in_recoded(floor(behav_in_recoded(:,2)/1000)==1,:);
    
    behav_in_recoded(:,4)    =  behav_in_recoded(:,2) - 1000;
    behav_in_recoded(:,5)    =  floor(behav_in_recoded(:,4)/100);
    behav_in_recoded(:,6)    =  floor((behav_in_recoded(:,4)-100*behav_in_recoded(:,5))/10);     % Determine the DIS latency
    behav_in_recoded(:,7)    =  mod(behav_in_recoded(:,4),10);

    behav_in_recoded = behav_in_recoded(behav_in_recoded(:,6) == 0,:);
    
    for b = 1:4
        
        if b < 3
            ntrl_tot = length(behav_in_recoded(behav_in_recoded(:,5) == b,1));
            ntrl_cnd = length(behav_in_recoded(behav_in_recoded(:,5) == b & behav_in_recoded(:,3) == 0,1));
        elseif b == 3
            ntrl_tot = length(behav_in_recoded(mod(behav_in_recoded(:,7),2) ~= 0 & behav_in_recoded(:,5) == 0,1));
            ntrl_cnd = length(behav_in_recoded(mod(behav_in_recoded(:,7),2) ~= 0 & behav_in_recoded(:,5) == 0 & behav_in_recoded(:,3) == 0,1));
        else
            ntrl_tot = length(behav_in_recoded(mod(behav_in_recoded(:,7),2) == 0 & behav_in_recoded(:,5) == 0,1));
            ntrl_cnd = length(behav_in_recoded(mod(behav_in_recoded(:,7),2) == 0 & behav_in_recoded(:,5) == 0 & behav_in_recoded(:,3) == 0,1));
        end
        
        sub_per(a,b) = ntrl_cnd/ntrl_tot * 100;
        clear ntrl*
        
    end
    
    %     ntrl_tot    = length(behav_in_recoded(behav_in_recoded(:,5) < 3,1));
    %     ntrl_cnd    = length(behav_in_recoded(behav_in_recoded(:,5) < 3 & behav_in_recoded(:,3) == 0,1));
    %     sub_per{a}  = ntrl_cnd/ntrl_tot * 100;
    
    clear behav_in_recoded suj b
end

clearvars -except sub_per ;

mean_nl = squeeze(sub_per(:,3));
mean_nr = squeeze(sub_per(:,4));
mean_l  = squeeze(sub_per(:,1));
mean_r  = squeeze(sub_per(:,2));

perm1 = permutation_test([mean_r mean_l],10000);
perm2 = permutation_test([mean_r mean_nr],10000);
perm3 = permutation_test([mean_r mean_nl],10000);
perm4 = permutation_test([mean_l mean_nr],10000);
perm5 = permutation_test([mean_l mean_nl],10000);
perm6 = permutation_test([mean_nr mean_nl],10000);