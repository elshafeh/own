clear ; clc ;

cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/')

% [~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(73);

addpath('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/');

suj_list        = {'uc2'};

new_table   = [];

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    dirIN       = dir(['../data/' suj '/meeg/' suj '*regress0.eeg']);
    dirIN       = dirIN.name;
    
    posIn       = ['../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.pos'];
    posOUT      = ['../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.pos'];
    
    cd(['../data/' suj '/meeg/']);
    
    flag        = dir(['../../../par/eegavg_rej_new_' suj '.par']);
    
    if length(flag) == 1
        parIN           = ['../../../par/eegavg_rej_new_' suj '.par'];
    else
        parIN       = '../../../par/eegavg_rej_new.par';
    end
    
    system(['eegavg ' dirIN ' ' posIn ' ' parIN ' ' posOUT ' +v']);
    system(['mv ' parIN '.res ../res/' suj '.' parIN(14:end) '.res']);
    
    system('rm tempo_rej*p');
    
    cd('../../../scripts.m/');
    
    summary_table = h_funk_trialLossNew(suj);
    
    new_table     = [new_table;summary_table];
    
end