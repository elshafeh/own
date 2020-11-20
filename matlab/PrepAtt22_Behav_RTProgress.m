clear ; clc ; close all;

% [~,suj_list,~]  = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list        = suj_list(2:end);
% lst_group       = {'o','y','m','f','u'};
%
% for g = 1:length(lst_group)
%     suj_group{g} = {};
% end
%
% for sb = 1:length(suj_list)
%
%     ix = find(strcmp(lst_group,suj_list{sb}(1)));
%     suj_group{ix}{end+1} = suj_list{sb};
%
% end
%
% clearvars -except suj_group

behav_table = readtable('../documents/PrepAtt22_behav_table4R_withTukey.csv','Delimiter',';');

i           = 0;

for bg = [1 3]
    
    %     figure;
    %     hold on;
    
    for ngroup = [bg bg+1] %unique(behav_table.idx_group)'
        
        lst_color   = 'rbgc';
        
        group_table = behav_table(behav_table.idx_group==ngroup,:);
        
        for sb = unique(group_table.sub_idx)'
            
            suj_table           = group_table(group_table.sub_idx == sb,:);
            
            for nb = unique(suj_table.nbloc)'
            
                
                i = i+1;
                
                bloc_table_tuk      = suj_table(suj_table.nbloc==nb & suj_table.CORR ==1 & suj_table.DIS == 0,11);
                
                %                 progress_summary{ngroup}(i,nb) = median(bloc_table_tuk.RT);
                
                group_list          = {'old','young','patient','control'};
                summary{i,1}        = ['sub' num2str(sb)];
                summary{i,2}        = group_list{ngroup};
                summary{i,3}        = ['b' num2str(nb)];
                summary{i,4}     = median(bloc_table_tuk.RT);
                
                
            end
            
            %             progress_summary{ngroup}(i,:)   = progress_summary{ngroup}(i,:)/progress_summary{ngroup}(i,1);
            
        end
        
        %         plot_mean_std(mean(progress_summary{ngroup},1),std(progress_summary{ngroup},1),lst_color(ngroup));
        %         ylim([450 800])
        %     ylim([0 1])
        %         xlim([1 10])
        
    end
    
end

clearvars -except summary ;

summary_table = array2table(summary,'VariableNames',{'SUJ' ;'Group';'NBloc'; 'MedianRT'});
writetable(summary_table,'../documents/PrepAtt22_RTEvolution.csv','Delimiter',';')