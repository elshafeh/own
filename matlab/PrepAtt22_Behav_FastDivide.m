clear ; clc ;

behav_table = readtable('../documents/PrepAtt22_behav_table4R_withTukey.csv','Delimiter',';');

for ngroup = unique(behav_table.idx_group)'
    
    group_table = behav_table(behav_table.idx_group==ngroup,:);
    medianRT    = [];
   
    for sb = unique(group_table.sub_idx)'
        suj_table           = group_table(group_table.sub_idx == sb ,:);
        rt_table            = suj_table(suj_table.CORR ==1 & suj_table.DIS == 0,:);
        medianRT(sb,1)      = median(rt_table.RT);
    end
    
    for sb = unique(group_table.sub_idx)'
        
        suj_table           = group_table(group_table.sub_idx == sb ,:);
        
        if medianRT(sb,1) < median(medianRT)
            cde = 'fast';
        else
            cde = 'slow';
        end
        
        for j = 1:size(suj_table,1)
            tmp_table{j,1} = cde;
        end
        
        tmp_table = array2table(tmp_table,'VariableNames',{'Speed'});
        
        if ngroup == 1 && sb == 1
            new_table = [suj_table tmp_table];
        else
            new_table = [new_table; suj_table tmp_table];
        end
        
        clear tmp_table
        
    end
end

clearvars -except new_table

writetable(new_table,'../documents/PrepAtt22_behav_hesham_table4R_withTukey_withSpeedCategory.csv','Delimiter',';')