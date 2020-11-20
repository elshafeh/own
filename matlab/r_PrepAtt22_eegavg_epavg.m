function r_PrepAtt22_eegavg_epavg(list_all_suj,data)

clear ; clc ; close all;

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
% list_all_suj = {'yc9'}
%
% data     = {'eeg','meg'};

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    system(['mkdir ../data/' suj '/erp']);
    
    for d=1:length(data) %eeg ou meg
        
        if strcmp(suj,'yc9')==1 && strcmp(data{d},'eeg')==1
            
            disp('no EEG for this subject')
            
        else
            
            system(['mkdir ../data/' suj '/erp/' data{d} '/tempo']);
            
            cd(['../data/' suj '/erp/' data{d} '/tempo']);
            
            EEGfile    = ['../../../meeg/' suj '.pat22.preprocess4ERP.0.2_40.eeg'];
            posfileIN  = ['../../../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
            parfile    = ['../../../../../par/eegavg-' data{d} '.par'];
            posfileOUT = [ suj '.tmp.pos'];
            
            ligne = ['eegavg ' EEGfile ' ' posfileIN ' ' parfile ' ' posfileOUT ' +norejection'];
            system(ligne)
            
            ligne = ['mv ' parfile '.res ' '../../../res/']
            system(ligne)
            
                        ligne = ['../../../../../scripts.m/bash_auto-epavg ' suj]; %on reprend le script bash d'avant
                        %ligne = ['../../../../../scripts.m/bash_auto-epavg_fdis ' suj];
                        system(ligne);
            
%             %%%CUE CnD
%             
%             FicName     = ['batch.epavg'];
%             fid         = fopen(FicName,'w+');
%             fprintf(fid,'#!/bin/bash\n');
%             fprintf(fid,'\n');
%             fprintf(fid,'epavg<<!\n');
%             event_cnd = [1101 1103 1202 1204 1101 1003 1002 1004];
%             
%             for bloc = 0:9
%                 
%                 for half = 1:2
%                     
%                     fprintf(fid,'epavg<<!\n');
%                     
%                     for e = event_cnd
%                         
%                         fprintf(fid,'%d\n',100000*half+10000*bloc+e)
%                         
%                     end
%                     
%                     fprintf(fid,'\n');
%                     fprintf(fid,'!\n');
%                     fprintf(fid,'\n');
%                     
%                 end
%                 
%             end
%                         
%             fclose(fid);
            
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
            
            system('rm batch.epavg');
            
                       
            cd ../../../../../scripts.m
            
            
        end
        
    end
    
end
        
    
    