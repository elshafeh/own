function PrepAtt2_funk_RTEvolve(behav_summary)

nm_group = unique(behav_summary.idx_group);
figure;

for g = 1:length(nm_group)
    
    nm_suj = height(unique(behav_summary(behav_summary.idx_group == g,1)));
    
    for s = 1:nm_suj
        
        nb_bloc = sort(table2array(unique(behav_summary(behav_summary.idx_group == g & behav_summary.sub_idx == s,2))));
        
        for blc  = 1:length(nb_bloc)
            RT(s,blc) = median(table2array(behav_summary(behav_summary.idx_group == g & behav_summary.sub_idx == s & behav_summary.nbloc == nb_bloc(blc) & ...
                behav_summary.CORR == 1 & behav_summary.DIS == 0,11)));            
        end
        
    end
    
    quadr_corr = mean(RT,1);
    quadr_sem  = std(RT,1)/sqrt(nm_suj);
    
    subplot(1,2,g)
    errorbar(quadr_corr,quadr_sem)
    xlim([0 size(RT,2)+1])
    ylim([400 700])
    title(['Group ' num2str(g)]);
end