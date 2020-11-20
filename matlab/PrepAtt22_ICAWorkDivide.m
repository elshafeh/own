clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list        = suj_list(2:end);

list{1} = {};
list{2} = {};
list{3} = {};

for sb = 1:3:length(suj_list)
    for j = 1:3
        if j <= length(suj_list)
            list{j}{end+1,1} = suj_list{sb+j-1};
        end
        
    end
end

clearvars -except list 

lst_name = {'Hesham','Lesly','Remi'};

for j = 1:3
    for xi = 1:length(list{j})     
        list{j}{xi,2} = lst_name{j};
        list{j}{xi,3} = {};
    end
end

workdivide = [list{1};list{2};list{3}];

clearvars -except workdivide 

summary_table = array2table(workdivide,'VariableNames',{'SUJ' ;'Who';'Done'});
writetable(summary_table,'../documents/PrepAtt22_IcaWorkDivide.csv','Delimiter',';')