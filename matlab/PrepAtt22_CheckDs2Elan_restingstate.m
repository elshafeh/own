clear ; clc ;i           = 0;

% suj_list    = dir('/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/Sensor_Jumps/_old/');

suj_list = struct('name',{'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'});

addpath(genpath('../../../fieldtrip-20151124/'));

for sb = 1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        suj                     = suj_list(sb).name;
        i                       = i + 1 ;
        
        fname                   = dir(['../rawdata/' suj '/*_CAT_*.misc']);
        fname                   = strsplit(fname.name,'_');
        fname                   = strsplit(fname{3},'.');
        fname                   = fname{1};

    
        suj_ddn                 = str2double(fname); clear fname ;
        dirElanOut              = ['../data/' suj '/meeg/' suj '.restingstate.meeg.eeg'];
        
        [m_data,m_events,~,~,~,s_nb_channel_all,v_label_all,~,~,~,~] = eeg2mat(dirElanOut,200,210,'all');
        
        summary{i,1}           = suj;
        summary{i,2}           = suj_ddn;
        
        for n = 1:length(v_label_all)
            summary{i,n+2}     = v_label_all{n};
        end
        
    end
    
end

clearvars -except summary

elec_legend{1} = 'SUB';
elec_legend{2} = 'DataMEG';

for n = 3:size(summary,2)
    elec_legend{n} = ['elec' num2str(n-2)];
end

summary                 = array2table(summary,'VariableNames',elec_legend);
[summary_sorted,index]  = sortrows(summary,'DataMEG');

writetable(summary_sorted,'../documents/pick_jump_CheckElanConversion_restingstate.csv','Delimiter',';');