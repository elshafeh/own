clear ; clc ;

addpath('../scripts.field/');

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup      = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        [~,~,~,behav_table] = h_new_behav_eval_camille(suj);
        
        list_table    = {};
        list_table{1} = 'SUB';
        
        list_cue        = {'Uninformative_Cue','Left_Cue','Right_Cue'};
        list_dis        = {'NoDis','DIS1','DIS2'};
        list_target     = {'Left_Low_Target','Right_Low_Target','Left_High_Target','Right_High_Target'};
        
        table_out{sb,1} = suj ;
        
        i        = 1;
        
        for ncue = 1:3
            for ndis = 1:3
                for ntarget = 1:4
                    
                    if (strcmp(list_target{ntarget}(1),'R') && strcmp(list_cue{ncue}(1),'L')) || (strcmp(list_target{ntarget}(1),'L') && strcmp(list_cue{ncue}(1),'R'))
                        
                        fprintf('Tu deconnes ou quoi??\n');
                    else
                        
                        i                   = i + 1;
                        table_out{sb,i}     = height(behav_table(behav_table.CUE == ncue -1 & behav_table.DIS == ndis -1 & behav_table.TAR == ntarget,11));
                        list_table{end+1}   = [list_cue{ncue} '_' list_dis{ndis} '_' list_target{ntarget}];
                        
                    end
                    
                end
            end
        end
    end
end

clearvars -except list_table table_out

summary_table             = array2table(table_out,'VariableNames',list_table);
writetable(summary_table,'../documents/PrepAtt22_FurCamille_TrialCount.csv','Delimiter',';')