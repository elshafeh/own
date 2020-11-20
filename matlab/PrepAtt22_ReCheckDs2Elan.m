clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/temp/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list        = suj_list(2:end);

load('../documents/pick_jump_ElanConcatFileToUse.mat'); summary = table2array(summary) ;

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
    
    fname                   = dir(['../rawdata/' suj '/*_CAT_*.misc']);
    fname                   = strsplit(fname.name,'_');
    fname                   = strsplit(fname{3},'.');
    fname                   = fname{1};
    
    suj_ddn                 = str2double(fname); clear fname ;
    
    flag                    = find(strcmp(summary(:,1),suj));
    
    dirElanOut              = ['../data/' suj '/meeg/' summary{flag,2} '.eeg'];
    
    [m_data,m_events,~,~,~,s_nb_channel_all,v_label_all,~,~,~,~] = eeg2mat(dirElanOut,200,210,'all');
    
    summary{sb,3}           = suj_ddn;
    
    for n = 1:length(v_label_all)
        summary{sb,n+3}     = v_label_all{n};
    end
    
end

clearvars -except summary

elec_legend{1} = 'SUB';
elec_legend{2} = 'EEGFile';
elec_legend{3} = 'DataMEG';

for n = 4:size(summary,2)
    elec_legend{n} = ['elec' num2str(n-3)];
end

summary                 = array2table(summary,'VariableNames',elec_legend);
[summary_sorted,index]  = sortrows(summary,'DataMEG');

writetable(summary_sorted,'../documents/pick_ReCheckElanConversion.csv','Delimiter',';');