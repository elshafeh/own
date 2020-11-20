function PrepAtt2_funk_NoDisCueEffect(behav_summary)

nm_group = unique(behav_summary.idx_group);

for g = 1:length(nm_group)
    
    nm_suj = height(unique(behav_summary(behav_summary.idx_group == g,1)));
    
    for s = 1:nm_suj
        
        for ncue = 1:2
            
            dis             = 0;
            RT(ncue)        = median(table2array(behav_summary(behav_summary.idx_group == g & behav_summary.sub_idx == s & behav_summary.CORR == 1 & behav_summary.cue_idx == ncue & behav_summary.DIS == dis,11)));
            
        end
    
        rtDifference(s) = RT(1) - RT(2);     clear RT ;
        
    end
    
    quadr_corr(g) = mean(rtDifference);
    quadr_sem(g)  = std(rtDifference)/sqrt(length(rtDifference));
    
    clear rtDifference ;
    
end

figure;
errorbar(quadr_corr,quadr_sem,'LineWidth',2);
set(gca,'Xtick',0:1:nm_group+1)
xlim([0 3])
% ylim([-30 0])
set(gca,'Xtick',0:5,'XTickLabel', {'','Group1','Group2',''})