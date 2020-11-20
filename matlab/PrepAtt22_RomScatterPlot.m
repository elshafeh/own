clear ; clc ;

behav_table = readtable('../documents/PrepAtt22_behav_table4R_withTukey.csv','Delimiter',';');
i           = 0;
lst_group   = {'old','young','patient','control'};

for ngroup = unique(behav_table.idx_group)'
    
    %     figure;
    
    slct_summary      = behav_table(behav_table.idx_group==ngroup & behav_table.CORR >0,:);
    slct_summary      = table2array(slct_summary);
    %     PrepAtt22_funk_evalplot(slct_summary)
    %     title([lst_group{ngroup} ' No Tukey']);
    
    floor([min(slct_summary(:,11)) max(slct_summary(:,11))])
    
    %     figure;
    
    slct_summary      = behav_table(behav_table.idx_group==ngroup & behav_table.CORR == 1,:);
    slct_summary      = table2array(slct_summary);
    %     PrepAtt22_funk_evalplot(slct_summary)
    %     title([lst_group{ngroup} ' Tukey']);
    
    floor([min(slct_summary(:,11)) max(slct_summary(:,11))])
    
end

clearvars -except summary ;