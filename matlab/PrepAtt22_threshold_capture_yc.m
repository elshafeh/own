clear ; clc ;

fname_in        = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/PrepAtt22_sensation_values.csv';
sens_table      = readtable(fname_in);

[~,suj_group{1},~]  = xlsread('~/GoogleDrive/PhD/Fieldtripping/documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);


% [~,allsuj,~]    = xlsread('~/GoogleDrive/PhD/Fieldtripping/documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

final_table                     = {};

for ngroup = 1:length(suj_group)
    for sb = 1:length(suj_group{ngroup})
        
        suj                     = suj_group{ngroup}{sb};
        suj_val                 = sens_table(strcmp(sens_table.SUB,suj),:);
        suj_val                 = table2cell(suj_val);
        suj_val{1,5}            = [suj(1:2) 'group'];
        
        final_table             = [final_table;suj_val];
        
    end
end

clearvars -except final_table ;

target_level                    = cell2mat(final_table(:,3));
dist_level                      = cell2mat(final_table(:,4));

% final_table      = array2table(final_table,'VariableNames',{'SUB','Threshold','Target_level','Distracor_level','GROUP'});