function [quadr_corr,quadr_sem] = PrepAtt2_funk_behav_quadplot_rt(behav_summary)

nm_group = unique(behav_summary.idx_group);

% if length(nm_suj) >1
%     dirOUT = '/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.check/';
%     suj = 'tot';
% else
%     dirOUT = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/behav/'];
% end

for g = 1:length(nm_group)
    
    nm_suj = height(unique(behav_summary(behav_summary.idx_group == g,1)));
    
    for d = 1:2
        for c = 1:3
            
            rt_all  = [];
            dis     = c-1;
            
            for s = 1:nm_suj
                
                RT = median(table2array(behav_summary(behav_summary.idx_group == g & behav_summary.sub_idx == s & behav_summary.CORR == 1 & behav_summary.cue_idx == d & behav_summary.DIS == dis,11)));
                rt_all = [rt_all;RT];
                
            end
            
            quadr_corr(g,c,d) = mean(rt_all);
            quadr_sem(g,c,d)  = std(rt_all)/sqrt(length(rt_all));
            
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
ylim([min(min(min(quadr_corr)))-min(min(min(quadr_sem)))-50 max(max(max(quadr_sem)))+max(max(max(quadr_corr)))+50])
set(gca,'Xtick',0:5,'XTickLabel', {'','NoDis','DIS1','DIS2',''})