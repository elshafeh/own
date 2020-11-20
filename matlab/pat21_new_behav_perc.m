clear ; clc ;

suj_list = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj                      = ['yc' num2str(suj_list(a))];
    behav_in_recoded         = load(['../data/pos/' suj '.pat2.newrec.behav.pos']);
    behav_in_recoded         = behav_in_recoded(floor(behav_in_recoded(:,2)/1000)==1,:);
    
    behav_in_recoded(:,4)    =  behav_in_recoded(:,2) - 1000;
    behav_in_recoded(:,5)    =  floor(behav_in_recoded(:,4)/100);
    behav_in_recoded(:,6)    =  floor((behav_in_recoded(:,4)-100*behav_in_recoded(:,5))/10);     % Determine the DIS latency
    behav_in_recoded(:,7)    =  mod(behav_in_recoded(:,4),10);

    behav_in_recoded = behav_in_recoded(behav_in_recoded(:,6) == 0,:);
    
    for b = 1:3
        
        ntrl_tot = length(behav_in_recoded(behav_in_recoded(:,5) == b-1,1));
        ntrl_cnd = length(behav_in_recoded(behav_in_recoded(:,5) == b-1 & behav_in_recoded(:,3) == 0,1));
        
        sub_per(a,b) = ntrl_cnd/ntrl_tot * 100;
        clear ntrl*
        
    end
    
end

clearvars -except sub_per ;

save ../data/yctot/gavg/NLR_CnD_percentage_correct_gavg.mat