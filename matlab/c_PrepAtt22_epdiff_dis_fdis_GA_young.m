%% epdiff dis-fdis sur les GA pool jeunesse 
cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m');
load ../documents/event.mat; %structure 'event'
data = {'eeg','meg'};
ext  = '.lb' ;

% data = 'meg';
% ext = '.lb.gfp'; 

for d = 1:length(data) %eeg ou meg
    
    cd(['../data/avg_young/erp/' data{d} ]);
    % cd(['../data/avg_young/erp/' data ]);
    mkdir('dis-fdis');
    
    event_list = getfield(event, 'dis');
    
    
    for cat = 1:length(event_list)
        
        system('rm batch.epdiff');
        
        epfileIN1  = [ 'dis/young.pat22.' event_list{cat} ext];
        epfileIN2  = [ 'fdis/young.pat22.f' event_list{cat} ext];
        epfileOUT  = [ 'dis-fdis/young.pat22.' event_list{cat} ext '.dis-fdis'];
        
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
    cd ../../../../scripts.m
end

