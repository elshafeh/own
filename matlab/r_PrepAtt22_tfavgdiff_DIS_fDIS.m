clear ; clc ; close all;

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
load ../documents/event.mat; %structure 'event'
ext  = '.avg.tf' ;

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    
    cd(['../data/' suj '/tf' ]);
    mkdir('dis-fdis');
    
    event_list = getfield(event, 'dis');   
    
    for cat = 1:length(event_list)
        
        system('rm batch.epdiff');
        
        tffileIN1  = [ 'dis/' suj '.pat22.' event_list{cat} ext];
        tffileIN2  = [ 'fdis/' suj '.pat22.f' event_list{cat} ext];
        tffileOUT  = [ 'dis-fdis/' suj '.pat22.' event_list{cat}  '.dis-fdis' ext];
        
        ligne = ['rm dis-fdis/' tffileOUT '.p']
        system(ligne)
        
        FicName     = 'batch.epdiff';
        fid         = fopen(FicName,'w+');
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,'\n');
        fprintf(fid,'tfavgdiff<<!\n');
        fprintf(fid,'%s\n',tffileIN1);
        fprintf(fid,'%s\n',tffileIN2);
        fprintf(fid,'%s\n',tffileOUT);
        fprintf(fid,'\n\n');
        fprintf(fid,'!\n');
        fclose(fid);
        
        system(['chmod 777 ' FicName]);
        system(['bash ' FicName]);
        
        system('rm batch.epdiff');
        
    end
    
    
    cd ../../../scripts.m
    
    
end



