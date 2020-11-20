clear ; clc ; close all;

load('../documents/list_all_suj.mat'); %donne list_all_suj


for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    system(['mkdir ../data/' suj '/tf']);
    
    
    
    system(['mkdir ../data/' suj '/tf/' ]);
    system(['mkdir ../data/' suj '/tf/cue']);
    system(['mkdir ../data/' suj '/tf/dis']);
    system(['mkdir ../data/' suj '/tf/fdis']);
    system(['mkdir ../data/' suj '/tf/target']);
    system(['mkdir ../data/' suj '/tf/bp']);
    system(['mkdir ../data/' suj '/tf/tempo']);
    
    cd(['../data/' suj '/tf/tempo']);
    
    EEGfile    = ['../../meeg/' suj '.pat22.preprocess4ERP.0.2_40.eeg'];
    posfileIN  = ['../../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    parfile1   = ['../../../../par/tfavg-meg_mig_cue+dis.par' ];
    parfile2   = ['../../../../par/tfavg-meg_mig_target+bp.par' ];
    
    ligne      = ['tfavg ' EEGfile ' ' posfileIN ' ' parfile1 ' 2 +v']; %on sépare le traitement cue+dis de target+bp pour éviter de saturer la RAM
    system(ligne)
    ligne      = ['tfavg ' EEGfile ' ' posfileIN ' ' parfile2 ' 2 +v'];
    system(ligne)
    
    ligne      = ['../../../../scripts.m/bash_auto-tfavg ' suj]; %on reprend le script bash d'avant
    system(ligne);
    
    cd ../../../../scripts.m
    
end
    

        