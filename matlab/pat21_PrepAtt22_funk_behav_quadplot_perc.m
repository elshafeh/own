function PrepAtt2_funk_behav_quadplot_perc(behav_summary)

nm_group = unique(behav_summary.idx_group);

for g = 1:length(nm_group)
    
    nm_suj = height(unique(behav_summary(behav_summary.idx_group == g,1)));
    
    for d = 1:2
        for c = 1:3
            
            rt_all  = [];
            dis     = c-1;
            
            for s = 1:nm_suj
                
                len_cond = length(table2array(behav_summary(behav_summary.idx_group == g & behav_summary.sub_idx == s & behav_summary.CORR == 1 & behav_summary.cue_idx == d & behav_summary.DIS == dis,11)));
                len_tot  = length(table2array(behav_summary(behav_summary.idx_group == g & behav_summary.sub_idx == s & behav_summary.cue_idx == d & behav_summary.DIS == dis,11)));
                
                perc_all(s)  = (len_cond/len_tot) * 100; clear len_cond len_tot
                
            end
            
            quadr_corr(g,c,d) = mean(perc_all);
            quadr_sem(g,c,d)  = std(perc_all)/sqrt(length(perc_all));
            
            clear perc_all
            
        end
        
    end
end

figure
hold on
i   = 0 ;
for g = 1:length(nm_group)
    errorbar(squeeze(quadr_corr(g,:,1)),squeeze(quadr_sem(g,:,1)),'LineWidth',2)
    i = i + 1 ;
    lst_legend{i} = ['group' num2str(g) ' inf'];
    errorbar(squeeze(quadr_corr(g,:,2)),squeeze(quadr_sem(g,:,2)),'LineWidth',2)
    i = i + 1 ;
    lst_legend{i} = ['group' num2str(g) ' unf'];
end

legend(lst_legend,'Location', 'Northeast')
set(gca,'Xtick',0:1:5)
xlim([0 4])
ylim([85 100])
set(gca,'Xtick',0:5,'XTickLabel', {'','NoDis','DIS1','DIS2',''})