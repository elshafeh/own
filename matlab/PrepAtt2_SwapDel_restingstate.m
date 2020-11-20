clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

% [~,suj_list,~] = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list       = suj_list(2:end);

suj_list = {'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};


for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list_restingstate.mat']);
    
    fname                   = dir(['../rawdata/' suj '/*_CAT_*.misc']);
    fname                   = strsplit(fname.name,'_');
    fname                   = strsplit(fname{3},'.');
    fname                   = fname{1};
    
    suj_ddn                 = str2double(fname); clear fname ;
    
    dirElanIN               = ['../data/' suj '/meeg/' suj '.restingstate.meeg'];
    
    
    if strcmp(suj,'yc9')
        
        dirElanOUT                 = [dirElanIN '.delChan'];
        system(['eegdelchan ' dirElanIN '.eeg ' dirElanOUT '.eeg 1 346']);
        
    else
        
        if suj_ddn < 20170331
            
            dirElanOUT                 = [dirElanIN '.swap'];
            system(['eegswapchan ' dirElanIN ' ' dirElanOUT ' 314 315']);
            
            
        else
            
            dirElanOUT                 = dirElanIN;
            
        end
        
    end
    
    summary{sb,1} = dirElanOUT ;
    
end

clearvars -except summary ;

for n = 1:length(summary)
    tmp = strsplit(summary{n},'/');
    summary{n,1} = tmp{3};
    summary{n,2} = tmp{5};
end

clearvars -except summary ;

summary                 = array2table(summary,'VariableNames',{'SUB','EEG_FILE'});
writetable(summary,'../documents/ElanConcatFileToUse_restingstate.csv','Delimiter',';');

save('../documents/pick_jump_ElanConcatFileToUse_restingstate.mat','summary');