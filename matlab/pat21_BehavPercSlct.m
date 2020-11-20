clear ; clc ;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                      = ['yc' num2str(suj_list(sb))];
    behav_in_recoded         = load(['../data/pos/' suj '.pat2.newrec.behav.pos']);
    behav_in_recoded         = behav_in_recoded(floor(behav_in_recoded(:,2)/1000)==1,:);
    
    behav_in_recoded(:,4)    =  behav_in_recoded(:,2) - 1000;
    behav_in_recoded(:,5)    =  floor(behav_in_recoded(:,4)/100);
    behav_in_recoded(:,6)    =  floor((behav_in_recoded(:,4)-100*behav_in_recoded(:,5))/10);     % Determine the DIS latency
    behav_in_recoded(:,7)    =  mod(behav_in_recoded(:,4),10);

    behav_in_recoded = behav_in_recoded(behav_in_recoded(:,6) == 0,:);
    
    ntrl_tot = length(behav_in_recoded);
    ntrl_cnd = length(behav_in_recoded(behav_in_recoded(:,5) == b-1 & behav_in_recoded(:,3) == 0,1));
    
    sub_per{sb} = ntrl_cnd/ntrl_tot * 100;
    
end