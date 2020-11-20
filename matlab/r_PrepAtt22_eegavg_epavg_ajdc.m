function r_PrepAtt22_eegavg_epavg_ajdc(list_all_suj,data)

% clear ; clc ; close all;

%load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
% list_all_suj = {'yc9'}
% list_all_suj = {'mg1','mg2','mg3'};
% data     = {'eeg','meg'};

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    system(['mkdir ../data/' suj '/erp_ajdc']);

    for d=1:length(data) %eeg ou meg
        
        if strcmp(suj,'yc9')==1 && strcmp(data{d},'eeg')==1
            
            disp('no EEG for this subject')
            
        else
            
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d}]);
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d} '/cue']);
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d} '/dis']);
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d} '/fdis']);
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d} '/target']);
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d} '/bp']);
            system(['mkdir ../data/' suj '/erp_ajdc/' data{d} '/tempo']);
            
            cd(['../data/' suj '/erp_ajdc/' data{d} '/tempo']);
            
            EEGfile    = ['../../../meeg/' suj '.pat22.preprocess4ERP_ajdc.0.2_40.eeg ']; %['../../../meeg/' suj '']; 
            posfileIN  = ['../../../pos/' suj '.pat22.rec.behav.fdis.bad.pos']; % fichier pos avec un problème pour les fdis
            parfile    = ['../../../../../par/eegavg-' data{d} '_ajdc.par'];
            posfileOUT = [ suj '.tmp.pos'];
            
            ligne = ['eegavg ' EEGfile ' ' posfileIN ' ' parfile ' ' posfileOUT ' +norejection'];
            system(ligne)
            
            ligne = ['mv ' parfile '.res ' '../../../res/']
            system(ligne)
            
            ligne = ['../../../../../scripts.m/bash_auto-epavg_ajdc ' suj]; %on reprend le script bash d'avant
            %ligne = ['../../../../../scripts.m/bash_auto-epavg_fdis ' suj];
            system(ligne);
            
            cd ../../../../../scripts.m
            
        end
        
    end
    
end
        
    
    