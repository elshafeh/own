clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/temp/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list        = suj_list(2:end);
suj_list = {'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};


load('../documents/pick_jump_ElanConcatFileToUse_restingstate.mat'); summary = table2array(summary) ;

trialpot = [];

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    ElanFile                = ['../data/' suj '/meeg/' summary{sb,2} '.eeg'];
    
    if exist(ElanFile,'file')
        
        PosFile                     = ['../data/' suj '/pos/' suj '.restingstate.pos'];
        
        if ~exist (PosFile,'file')
            system(['eegpos ' ElanFile ' ' PosFile]);
        end
        
    end
    
end