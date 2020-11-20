clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);
%ext = '';
ext = '.L-N';

for sb=1:length(list_all_suj)
    suj = list_all_suj{sb};
    
    for ev = 1:length(event_names) %bp, cue, dis, fdis, target
        
        cd(['../data/' suj '/erp/meg/' event_names{ev}]);
        event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
        
        for cat = 1:length(event_list)
            
            epfileIN  = [suj '.pat22.' event_list{cat} '.lb' ext];
            epfileOUT = [epfileIN '.gfp'];
            
            ligne = ['rm ' epfileOUT '.p']
            system(ligne)
            
            FicName     = ['batch.eprms'];
            fid         = fopen(FicName,'w+');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'\n');
            fprintf(fid,'eprms<<!\n');
            fprintf(fid,'%d\n',0);
            fprintf(fid,'%s\n',epfileIN);
            fprintf(fid,'%s\n',epfileOUT);
            fprintf(fid,'\n');
            fprintf(fid,'!\n');
            fclose(fid);
            
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
            
            system('rm batch.eprms');
            
        end
        cd ../../../../../scripts.m
        
    end
    
end

