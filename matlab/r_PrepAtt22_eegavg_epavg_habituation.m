clear ; clc ; close all;

%load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
% list_all_suj = {'yc9'}
%

ctl = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
        'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};
mig = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
        'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
list_all_suj = [ctl mig];


data     = {'eeg','meg'};

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    system(['mkdir ../data/' suj '/erp']);
    
    for d=1:length(data) %eeg ou meg
        
        if strcmp(suj,'yc9')==1 && strcmp(data{d},'eeg')==1
            
            disp('no EEG for this subject')
            
        else
            
            system(['mkdir ../data/' suj '/erp/' data{d} '/tempo']);
            
            cd(['../data/' suj '/erp/' data{d} '/tempo']);
            
%             EEGfile    = ['../../../meeg/' suj '.pat22.preprocess4ERP.0.2_40.eeg'];
%             posfileIN  = ['../../../pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.habituation.pos'];
%             parfile    = ['../../../../../par/eegavg-' data{d} '_habituation.par'];
%             posfileOUT = [ suj '.tmp.pos'];
%             
%             ligne = ['eegavg ' EEGfile ' ' posfileIN ' ' parfile ' ' posfileOUT ' +norejection'];
%             system(ligne)
%             
%             ligne = ['mv ' parfile '.res ' '../../../res/'];
%             system(ligne)
            

%             %%%CUE CnD
%             
%             FicName     = ['batch.epavg'];
%             fid         = fopen(FicName,'w+');
%             fprintf(fid,'#!/bin/bash\n');
%             fprintf(fid,'\n');
%             fprintf(fid,'epavg<<!\n');
%             
             event_cnd = [1101 1103 1202 1204 1001 1003 1002 1004];
%             
%             for bloc = 0:9
%                 
%                 for half = 1:2
%                     
%                     
%                     fprintf(fid,'%s\n\n',['../cue/' suj '.pat22.CnD.b' num2str(bloc+1) 'half' num2str(half)]);
%                     
%                     for e = event_cnd
%                         
%                         fprintf(fid,'%s\n',['tempo.' num2str(100000*half+10000*bloc+e)]);
%                         
%                     end
%                     
%                     fprintf(fid,'\n');
%                     
%                 end
%                 
%             end
%             
%             fprintf(fid,'\n');
%             fprintf(fid,'!\n');
%             fprintf(fid,'\n');
%             fclose(fid);
%             
%             system(['chmod 777 ' FicName]);
%             system(['bash ' FicName]);
%             
%             system('rm batch.epavg');
%             
%             %%%DIS
%             
%             FicName     = ['batch.epavg'];
%             fid         = fopen(FicName,'w+');
%             fprintf(fid,'#!/bin/bash\n');
%             fprintf(fid,'\n');
%             fprintf(fid,'epavg<<!\n');                        
%             event_dis = [2111 2113 2121 2123 2212 2214 2222 2224 2013 2023 2012 2014 2022 2024];
%             
%             for bloc = 0:9
%                 
%                 for half = 1:2
%                     
%                     
%                     fprintf(fid,'%s\n\n',['../dis/' suj '.pat22.DIS.b' num2str(bloc+1) 'half' num2str(half)]);
%                     
%                     for e = event_dis
%                         
%                         fprintf(fid,'%s\n',['tempo.' num2str(100000*half+10000*bloc+e)]);
%                         
%                     end
%                     
%                     fprintf(fid,'\n');
%                     
%                 end
%                 
%             end
%             
%             fprintf(fid,'\n');
%             fprintf(fid,'!\n');
%             fprintf(fid,'\n');
%             fclose(fid);
%             
%             system(['chmod 777 ' FicName]);
%             system(['bash ' FicName]);
%             
%             system('rm batch.epavg');
%             
%             %%%fDIS
%             
%             FicName     = ['batch.epavg'];
%             fid         = fopen(FicName,'w+');
%             fprintf(fid,'#!/bin/bash\n');
%             fprintf(fid,'\n');
%             fprintf(fid,'epavg<<!\n');                        
%             event_fdis = event_dis + 4000;
%             
%             for bloc = 0:9
%                 
%                 for half = 1:2
%                     
%                     
%                     fprintf(fid,'%s\n\n',['../fdis/' suj '.pat22.fDIS.b' num2str(bloc+1) 'half' num2str(half)]);
%                     
%                     for e = event_fdis
%                         
%                         fprintf(fid,'%s\n',['tempo.' num2str(100000*half+10000*bloc+e)]);
%                         
%                     end
%                     
%                     fprintf(fid,'\n');
%                     
%                 end
%                 
%             end
%             fprintf(fid,'\n');
%             fprintf(fid,'!\n');
%             fprintf(fid,'\n');
%             fclose(fid);
%             
%             system(['chmod 777 ' FicName]);
%             system(['bash ' FicName]);
%             
%             system('rm batch.epavg');
            
            %%%target nDT
            
            FicName     = ['batch.epavg'];
            fid         = fopen(FicName,'w+');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'\n');
            fprintf(fid,'epavg<<!\n');                        
            event_ndt = event_cnd + 2000;
            
            for bloc = 0:9
                
                for half = 1:2
                    
                    
                    fprintf(fid,'%s\n\n',['../target/' suj '.pat22.nDT.b' num2str(bloc+1) 'half' num2str(half)]);
                    system(['rm ../target/' suj '.pat22.nDT.b' num2str(bloc+1) 'half' num2str(half) '.p'])
                    
                    for e = event_ndt
                        
                        fprintf(fid,'%s\n',['tempo.' num2str(100000*half+10000*bloc+e)]);
                        
                    end
                    fprintf(fid,'\n');
                    
                end
                
            end
            
            fprintf(fid,'\n');
            fprintf(fid,'!\n');
            fprintf(fid,'\n');
            fclose(fid);
            
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
            
            system('rm batch.epavg');
            
            
            
            cd ../../../../../scripts.m
            
            
        end
        
    end
    
end
        
    
    