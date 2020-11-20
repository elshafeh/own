clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

%load('../documents/list_all_suj.mat'); %list_all_suj

list_all_suj = {'yc9'};

for sb = 1:length(list_all_suj)
    
    suj = list_all_suj{sb};
       
    cd(['../data/' suj '/meeg/'])
    
    %%filtrage MEG
    EEGfileIN   = [ suj '.pat22.*.OnlyEEG.icacorrMEG.regress0.eeg'];
    EEGfileTEMP = [ suj '.pat22.preprocess.temp.eeg'];
    posfile     = [ '../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    parfileMEG  = '../../../par/meg.epoch.bp0.2_40.o2.par'
   
    ligne       = ['eegepochfiltfilt ' EEGfileIN ' ' parfileMEG ' ' posfile ' ' EEGfileTEMP];
        
    system(ligne);
    
    %%filtrage EEG
    EEGfileOUT  = [ suj '.pat22.preprocess4ERP.0.2_40.eeg'];
    parfileEEG  = '../../../par/eeg.epoch.bp0.2.o2.par'
    
    if strcmp(suj,'yc9')        
        ligne = ['cp ' EEGfileTEMP ' ' EEGfileOUT];
        system(ligne); 
        ligne = ['cp ' EEGfileTEMP '.ent ' EEGfileOUT '.ent'];
        system(ligne);
    else           
        ligne       = ['eegepochfiltfilt ' EEGfileTEMP ' ' parfileEEG ' ' posfile ' ' EEGfileOUT];        
        system(ligne);
    end
    
    ligne = 'rm *temp*';
    system(ligne);

    cd ../../../scripts.m/
end




