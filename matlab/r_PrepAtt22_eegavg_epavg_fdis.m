clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
%list_all_suj = {'yc9'}

data     = {'eeg','meg'};

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    %     system(['mkdir ../data/' suj '/erp']);
    
    for d=1:length(data) %eeg ou meg
        
        %         system(['mkdir ../data/' suj '/erp/' data{d}]);
        %         system(['mkdir ../data/' suj '/erp/' data{d} '/cue']);
        %         system(['mkdir ../data/' suj '/erp/' data{d} '/dis']);
        %         system(['mkdir ../data/' suj '/erp/' data{d} '/fdis']);
        %         system(['mkdir ../data/' suj '/erp/' data{d} '/target']);
        %         system(['mkdir ../data/' suj '/erp/' data{d} '/bp']);
        %         system(['mkdir ../data/' suj '/erp/' data{d} '/tempo']);
        %
        if strcmp(suj,'yc9')==1 && strcmp(data{d},'eeg')==1
            
            disp('no EEG for this subject')
            
        else
            
            cd(['../data/' suj '/erp/' data{d} '/tempo']);
            
            EEGfile    = ['../../../meeg/' suj '.pat22.preprocess4ERP.0.2_40.eeg'];
            posfileIN  = ['../../../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
            parfile    = ['../../../../../par/eegavg-' data{d} '_fdis.par'];
            posfileOUT = [ suj '.tmp.pos'];
            
            %             ligne = ['eegavg ' EEGfile ' ' posfileIN ' ' parfile ' ' posfileOUT ' +norejection'];
            %             system(ligne)
            %
            %             ligne = ['mv ' parfile '.res ' '../../../res/' parfile '.fdis.res']
            %             system(ligne)
            
            ligne = ['../../../../../scripts.m/bash_auto-epavg_fdis ' suj]; %on reprend le script bash d'avant
            system(ligne);
            
            cd ../../../../../scripts.m
            
        end
        
    end
    
end

    
    