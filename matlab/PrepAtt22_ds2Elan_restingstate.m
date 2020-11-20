clear ; clc ; close all;
addpath(genpath('../../fieldtrip-20151124/'));

% [~,suj_list,~] = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list       = suj_list(2:end);
% suj_list    = dir('/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/Sensor_Jumps/_old/');

suj_list = { 'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};

ddn_list    = {};

for sb = 1:length(suj_list)
    
    % you need to account for the electrode names !
    
    suj                     = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list_restingstate.mat']);
    
    fname                   = dir(['../rawdata/' suj '/*_CAT_*.misc']);
    fname                   = strsplit(fname.name,'_');
    fname                   = strsplit(fname{3},'.');
    fname                   = fname{1};
    
    suj_ddn                 = str2double(fname); clear fname ;
    
    %     ddn_list{sb,1}          = [fname(7:8) '/' fname(5:6) '/' fname(1:4)];
    
    if suj_ddn < 20170331
        eegparname = '../../../par/ctf_meg275_eegmini.par';
    else
        eegparname = '../../../par/ctf_meg275_eegmini_new_config.par';
    end
    
    dirdata             = ['../data/' suj '/'];
    fOUT                = ['../data/' suj '/res/' suj '.ds2Elan.restingstate.txt'];
    system(['cp ../data/empty.txt ' fOUT]);
    
    diary on
    diary(fOUT)
    
    cd([dirdata 'ds']);
    
    dirDsIn                  = final_ds_list{2};
    dirElanOut               = ['../meeg/' suj '.restingstate.meeg.eeg'];
    
    if ~exist(dirElanOut)
        system(['ctf2eeg ' dirDsIn ' ' eegparname ' ' dirElanOut ' +v'])
    end
    

    diary off
    cd ../../../scripts.m/;
    
end