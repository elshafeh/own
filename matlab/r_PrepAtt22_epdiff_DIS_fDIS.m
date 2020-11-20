clear ; clc ; close all;

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
load ../documents/event.mat; %structure 'event'
data = {'eeg','meg'};
ext  = '.lb' ;

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    
    for d = 1:length(data) %eeg ou meg
        
        cd(['../data/' suj '/erp/' data{d} ]);
        mkdir('dis-fdis');
        
        event_list = getfield(event, 'dis');
        
        if strcmp(suj,'yc9')==1 && strcmp(data{d},'eeg')==1
            
            disp('no EEG for this subject')
            
        else       
            
            for cat = 1:length(event_list)
                
                system('rm batch.epdiff');
                
                epfileIN1  = [ 'dis/' suj '.pat22.' event_list{cat} ext];
                epfileIN2  = [ 'fdis/' suj '.pat22.f' event_list{cat} ext];
                epfileOUT  = [ 'dis-fdis/' suj '.pat22.' event_list{cat} ext '.dis-fdis'];
                
                ligne = ['rm dis-fdis/' epfileOUT '.p']
                system(ligne)
                
                FicName     = 'batch.epdiff';
                fid         = fopen(FicName,'w+');
                fprintf(fid,'#!/bin/bash\n');
                fprintf(fid,'\n');
                fprintf(fid,'epdiff<<!\n');
                fprintf(fid,'%s\n',epfileIN1);
                fprintf(fid,'%s\n',epfileIN2);
                fprintf(fid,'%s\n',epfileOUT);
                fprintf(fid,'\n\n');
                fprintf(fid,'!\n');
                fclose(fid);
                
                system(['chmod 777 ' FicName]);
                system(['bash ' FicName]);
                
                system('rm batch.epdiff');
                
            end
            
        end
        cd ../../../../scripts.m
    end
    
end

    

