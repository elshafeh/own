clear ; clc ;

[~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:73);
lst_group       = {'o','y','m','f','u'};

for g = 1:length(lst_group)
    suj_group{g} = {};
end

for sb = 1:length(suj_list)
    
    ix = find(strcmp(lst_group,suj_list{sb}(1)));
    suj_group{ix}{end+1} = suj_list{sb};
    
end

clearvars -except suj_group

behav_table = readtable('../documents/PrepAtt22_Allparticipants_behav_table4R_withTukey.csv','Delimiter',';');
i           = 0;

for ngroup = unique(behav_table.idx_group)'
    
    group_table = behav_table(behav_table.idx_group==ngroup,:);
    
    for sb = unique(group_table.sub_idx)'
        
        i                   = i+1;
        
        tot                 = size(group_table(group_table.sub_idx ==sb ,:),1);
        befor_tukey         = size(group_table(group_table.sub_idx ==sb & group_table.CORR>0,:),1);
        after_tukey         = size(group_table(group_table.sub_idx ==sb & group_table.CORR==1,:),1);
        
        summary{i,1}        = suj_group{ngroup}{sb};  
        summary{i,2}        = tot;
        summary{i,3}        = befor_tukey;          
        summary{i,4}        = after_tukey;          
        summary{i,5}        = (befor_tukey/tot)*100;          
        summary{i,6}        = (after_tukey/tot)*100;          

        
    end
    
end

clearvars -except summary ;

summary_table           = array2table(summary,'VariableNames',{'SUJ' ;'nTrials';'nTrials_Before'; 'nTrials_After';'Percentage_Before';'Percentage_After'});
writetable(summary_table,'../documents/PrepAtt22_TukeyImpact.csv','Delimiter',';')