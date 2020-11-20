clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/temp/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list        = suj_list(2:end);

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    fprintf('Handling %s\n',suj);
    
    
    PosFile                     = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.pos'];
    
    posIN                       = load(PosFile);
    
    pos_fdis                    = PrepAtt22_funk_pos_AddFakeDistractors(posIN);
    
    posnameout                  = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    
    dlmwrite(posnameout,pos_fdis,'Delimiter','\t' ,'precision','%10d');
    
end