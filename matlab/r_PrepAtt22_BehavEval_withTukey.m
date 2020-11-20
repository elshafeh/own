clear ; clc ; close all;

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

behav_summary   = [];

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        
        for nbloc = 1:size(final_ds_list,1)
            
            fprintf('Handling %s\n',[suj ' b' num2str(nbloc)])
            
            pos_single                = load(['../data/' suj '/pos/' final_ds_list{nbloc,1} '.code.pos']);
            pos_single                = PrepAtt22_funk_pos_prepare(pos_single,sb,nbloc,ngrp);
            pos_single                = PrepAtt22_funk_pos_recode(pos_single);
            [~,behav_single,~]        = PrepAtt22_funk_pos_summary(pos_single);
            
            behav_summary             = [behav_summary;behav_single];
            
            clear behav_single pos_single
            
        end
        
    end
end

clearvars -except behav_summary lst_group ; clc ; close all ;

behav_table                   = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ...
    ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ; ...
    'disON';'tarON';'CLASS';'idx_group';'unknown'});

new_table                      = [];

for ngroup = unique(behav_table.idx_group)'
    
    group_table = behav_table(behav_table.idx_group==ngroup,:);
    
    for sb = unique(group_table.sub_idx)'
        
        fprintf('Applying Tukey Outlier Exclusion On %s\n',['g' num2str(ngroup) 'sub' num2str(sb)]);
        
        suj_table                               = group_table(group_table.sub_idx ==sb,:);
        before_tukey                            = [table2array(suj_table(suj_table.CORR==1,11)) find((suj_table.CORR==1))];
        new_data                                = PrepAtt22_calc_tukey(before_tukey(:,1));
        
        suj_table.CORR(before_tukey(:,2))       = new_data(:,2);
        new_table                               = [new_table;suj_table];
        
        %         for cue = 1:3
        %             for dis = 1:3
        %                 for j = 1:size(before_tukey,1)
        %                     ix = find(behav_table.idx_group==ngroup & behav_table.sub_idx ==sb & behav_table.CUE ==cue-1 & behav_table.DIS==dis-1 & behav_table.nbloc==before_tukey.nbloc(j) ...
        %                         & behav_table.ntrl_blc == before_tukey.ntrl_blc(j));
        %
        %                     if behav_table.RT(ix) == before_tukey.RT(j) && length(ix) ==1
        %
        %                         behav_table.CORR(ix) = before_tukey.CORR(j);
        %                     else
        %                         error('something is wrong!')
        %                     end
        %                     clear ix
        %
        %                 end
        %                 clear before_tukey new_data
        %             end
        %         end
        
    end
end

clearvars -except behav_table new_table ;

writetable(new_table,'../documents/PrepAtt22_Allparticipants_behav_table4R_withTukey.csv','Delimiter',';')