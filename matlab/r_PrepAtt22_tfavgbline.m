function r_PrepAtt22_tfavgbline(list_all_suj,ev,window)

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
load ../documents/event.mat; %structure 'event'
ext = '.avg.tf';

for sb=1:length(list_all_suj)
    suj = list_all_suj{sb};
        
    cd(['../data/' suj '/tf/' ev]);
    event_list = getfield(event, ev); %toutes les catégories (ex. CnD CD1 CD2...)
    
    for cat = 1:length(event_list)
        
        tffileIN  = [suj '.pat22.' event_list{cat} ext];
        tffileOUT = [suj '.pat22.' event_list{cat} '.relch-600to-200ms.' ext];
        
        ligne = ['rm ' tffileOUT '.p']
        system(ligne)
        
        FicName     = ['batch.epbline'];
        fid         = fopen(FicName,'w+');
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,'\n');
        fprintf(fid,'tfavgbline<<!\n');
        fprintf(fid,'%s\n','y'); %baseline computed on the same file
        fprintf(fid,'%s\n','y');
        fprintf(fid,'%d\n',-600);
        fprintf(fid,'%d\n',-200);
        fprintf(fid,'%d\n',);
        fprintf(fid,'%s\n',tffileIN);
        fprintf(fid,'%s\n',tffileIN);
        fprintf(fid,'%s\n',tffileOUT);

        fprintf(fid,'\n');
        fprintf(fid,'!\n');
        fclose(fid);
        
        system(['chmod 777 ' FicName]);
        system(['bash ' FicName]);
        
        system('rm batch.epbline');
        
    end
    cd ../../../../scripts.m
    
    
end

