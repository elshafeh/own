clear ; clc ; dleiftrip_addpath ;

tname = '~/Dropbox/Fieldtripping/R/txt/PrepAtt22_behav_table4R.csv';
behav_in = readtable(tname);

i        = 0 ;

for g = 1:4
    
    group_table = behav_in(behav_in.CORR==1 & behav_in.idx_group ==g,:);
    suj_list    = unique(group_table.sub_idx);
    
    for sb = 1:length(suj_list)
        
        i = i +1 ;
        
        trial_count(i,1) = 0 ;
        trial_count(i,2) = 0 ;

        
        data_suj = group_table(group_table.sub_idx==sb,:);
        
        for cue = 1:3
            for dis = 1:3
                
                data        = data_suj(data_suj.CUE == cue-1 & data_suj.DIS==dis-1,11);
                data        = data.RT;
                new_data    = calc_tukey(data);
                
                trial_count(i,1) = trial_count(i,1) + length(data);
                trial_count(i,2) = trial_count(i,2) + length(new_data);

            end
        end
        
    end
    
end

clearvars -except trial_count

trial_count(:,3) = (trial_count(:,2)./trial_count(:,1))*100;