clear ; clc ; 

clear ; clc ;

cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/')

% [~,suj_list,~]  = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
% suj_list        = suj_list(2:end);

suj_list = {'oc10'};

addpath('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/');

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_eeg_file_list.mat'])
    
    dirIN       = [eeg_file_list{5,2} '.eeg'];
    
    dirOUT      = dir(['../data/' suj '/meeg/' suj '*regress0.eeg']);
    
    dirOUT      = dirOUT.name;
    
    parIn       = '../../../par/eegavg_regress_check.par';
    
    posIn       = ['../pos/' suj '.pat22.rec.behav.fdis.bad.pos'];
    
    posOUT      = ['../pos/' suj '.pat22.rec.behav.fdis.bad.tmp2.pos'];
    
    cd(['../data/' suj '/meeg/']);
    
    system('rm *ss*p');
    
    system(['eegavg ' dirIN ' ' posIn ' ' parIn ' ' posOUT ' +norejection']);
    
    batch_check(suj,'pre','regressCheck')
    
    system('rm tempo*')
    
    system(['eegavg ' dirOUT ' ' posIn ' ' parIn ' ' posOUT ' +norejection']);
    
    batch_check(suj,'post','regressCheck')
    
    system('rm tempo*');
    system('rm *batch');
    
    system(['rm ' parIn '.res']);
    
    cd('../../../scripts.m/')
    
end