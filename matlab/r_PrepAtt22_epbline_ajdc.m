function r_PrepAtt22_epbline_ajdc(list_all_suj,data)

%clear ; clc ; close all;

% load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
% list_all_suj = {'mg1','mg2','mg3'};
load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);
% data        = {'eeg','meg'};

%parfor
for sb=1:length(list_all_suj)
    suj = list_all_suj{sb};
    
    for d = 1:length(data) %eeg ou meg
        
        for ev = 1:length(event_names) %bp, cue, dis, fdis, target
            
            cd(['../data/' suj '/erp_ajdc/' data{d} '/' event_names{ev}]);
            event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
            
            for cat = 1:length(event_list)
                
                epfileIN  = [suj '.pat22.ajdc..' event_list{cat}];
                epfileOUT = [epfileIN '.lb'];
                
                ligne = ['rm ' epfileOUT '.p'];
                system(ligne)
                
                FicName     = ['batch.epbline'];
                fid         = fopen(FicName,'w+');
                fprintf(fid,'#!/bin/bash\n');
                fprintf(fid,'\n');
                fprintf(fid,'epbline<<!\n');
                fprintf(fid,'%s\n',epfileIN);
                fprintf(fid,'%s\n',epfileIN);
                fprintf(fid,'%s\n',epfileOUT);
                fprintf(fid,'%d\n',-100);
                fprintf(fid,'%d\n',0);
                fprintf(fid,'\n');
                fprintf(fid,'!\n');
                fclose(fid);
                
                system(['chmod 777 ' FicName]);
                system(['bash ' FicName]);
                
                system('rm batch.epbline');
                
            end
            cd ../../../../../scripts.m
            
        end
        
    end
    
end
    
    