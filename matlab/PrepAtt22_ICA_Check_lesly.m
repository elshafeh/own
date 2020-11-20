clear ; clc ;

cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/')

ICA_table = readtable('../documents/PrepAtt22_ICA_Comp_lesly.xlsx');
suj_list  = ICA_table.suj;

addpath('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/');

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_eeg_file_list.mat'])
    
    dirIN       = [eeg_file_list{5,2} '.eeg'];
    dirOUT      = [dirIN(1:end-4) '.icacorrMEG.eeg'];
    parIn       = '../../../par/eegavg_ICA_check.par';
    posIn       = ['../pos/' suj '.pat22.rec.behav.fdis.bad.pos'];
    posOUT      = ['../pos/' suj '.pat22.rec.behav.fdis.bad.tmp.pos'];
    
    cd(['../data/' suj '/meeg/']);
    
    system('rm *k.p')
    
    system(['eegavg ' dirIN ' ' posIn ' ' parIn ' ' posOUT ' +norejection']);
    
    batch_ica_check(suj,'pre')
    
    system('rm tempo*')
    
    system(['eegavg ' dirOUT ' ' posIn ' ' parIn ' ' posOUT ' +norejection']);
    
    batch_ica_check(suj,'post')
    
    system('rm tempo*')
    system('rm *batch')
    
    system([parIn '.res']);
    
    cd('../../../scripts.m/')
    
end