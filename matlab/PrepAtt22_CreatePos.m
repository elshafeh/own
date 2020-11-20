clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/temp/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list        = suj_list(2:end);
load('../documents/pick_jump_ElanConcatFileToUse.mat'); summary = table2array(summary) ;

trialpot = [];

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    ElanFile                = ['../data/' suj '/meeg/' summary{sb,2} '.eeg'];
    
    if exist(ElanFile,'file')
        
        PosFile                     = ['../data/' suj '/pos/' suj '.pat22.pos'];
        
        if ~exist (PosFile,'file')
            system(['eegpos ' ElanFile ' ' PosFile]);
        end
        
    end
    
end