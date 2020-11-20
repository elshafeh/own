clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list        = suj_list(2:end);

suj_list = {'mg19'};

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    cd(['../data/' suj '/meeg/'])
    
    if strcmp(suj,'fp3')
        dirElanIn               = dir('*EEG.eeg');
    else
        dirElanIn               = dir('*MEG.eeg');
    end
    
    if length(dirElanIn) == 1
        
        name_elan   = dirElanIn.name(1:end-4);
        name_pos    = ['../pos/' suj '.pat22.rec.behav.fdis.bad.pos'];
        
        if strcmp(suj,'fp4')
            name_par    = '../../../par/eeg_regress0_fp4.par';
        else
            name_par    = '../../../par/eeg_regress0.par';
        end
        system(['eegregress ' name_elan '.eeg ' name_pos ' ' name_par ' ' name_elan '.regress0.eeg']);
        
        system(['eegpos ' name_elan '.regress0.eeg ../pos/' suj '.icacorrMEG.regress0.pos']);
        
    end
    
    cd ../../../scripts.m/
    
    PrepAtt22_funk_Epochage_Check(suj)
    
end