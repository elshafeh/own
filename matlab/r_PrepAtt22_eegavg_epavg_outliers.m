%load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
list_all_suj = {'yc1' 'yc2' 'yc3' 'yc4' 'yc5' 'yc6' 'yc7' 'yc8' 'yc9' 'yc10' 'yc11' ...
    'yc12' 'yc13' 'yc14' 'yc15' 'yc16' 'yc17' 'yc18' 'yc19' 'yc20' 'yc21'};
% 
data     = {'eeg','meg'};

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    system(['mkdir ../data/' suj '/erp']);

    for d=1:length(data) %eeg ou meg
        
        system(['mkdir ../data/' suj '/erp/' data{d} '/tempo']);
       
        if strcmp(suj,'yc9')==1 && strcmp(data{d},'eeg')==1
            
            disp('no EEG for this subject')
            
        else
            
            cd(['../data/' suj '/erp/' data{d} '/tempo']);
            
            EEGfile    = ['../../../meeg/' suj '.pat22.preprocess4ERP.0.2_40.eeg']; 
            posfileIN  = ['../../../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.outliers.pos'];
            parfile    = ['../../../../../par/eegavg-' data{d} '_outliers.par'];
            posfileOUT = [ suj '.tmp.pos'];
            
            ligne = ['eegavg ' EEGfile ' ' posfileIN ' ' parfile ' ' posfileOUT ' +norejection'];
            system(ligne)
            
            ligne = ['mv ' parfile '.res ' '../../../res/']
            system(ligne)
            
            ligne = ['../../../../../scripts.m/bash_auto-epavg_outliers ' suj]; %on reprend le script bash d'avant
            %ligne = ['../../../../../scripts.m/bash_auto-epavg_fdis ' suj];
            system(ligne);
            
            cd ../../../../../scripts.m
            
        end
        
    end
    
end
        
    
    