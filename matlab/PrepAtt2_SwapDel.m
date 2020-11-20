clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

% [~,suj_list,~] = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list       = suj_list(2:end);

suj_list = {'oc6','mg19'};


for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
    
    fname                   = dir(['../rawdata/' suj '/*_CAT_*.misc']);
    fname                   = strsplit(fname.name,'_');
    fname                   = strsplit(fname{3},'.');
    fname                   = fname{1};
    
    suj_ddn                 = str2double(fname); clear fname ;
    
    dirElanIN               = ['../data/' suj '/meeg/' suj '.pat22.3rdOrder.jc.offset.meeg'];
    
    
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
writetable(summary,'../documents/ElanConcatFileToUse.csv','Delimiter',';');

save('../documents/pick_jump_ElanConcatFileToUse.mat','summary');