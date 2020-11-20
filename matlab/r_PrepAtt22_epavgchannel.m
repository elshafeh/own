clear ; clc ; close all;

load('../documents/list_all_suj.mat'); %donne 'list_all_suj'
load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);
ext         = '.lb';

FicName     = ['batch.epavgchannel'];
fid         = fopen(FicName,'w+');
fprintf(fid,'%d\n',1);
fprintf(fid,'%d\n',4);
fprintf(fid,'%d\n',1);
fprintf(fid,'%d\n',2);
fprintf(fid,'%d\n',4);
fprintf(fid,'%d\n',5);

for sb=1:length(list_all_suj)
    suj = list_all_suj{sb};
    
    if strcmp('fp3',suj)~=1 & strcmp('yc9',suj)~=1
        
        for ev = 1:length(event_names) %bp, cue, dis, fdis, target
            
            event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
            
            for cat = 1:length(event_list)
                
                epfileIN  = ['../data/' suj '/erp/eeg/' event_names{ev} '/' suj '.pat22.' event_list{cat} ext];
                epfileOUT = [epfileIN '.avgelec'];
                
                ligne = ['rm ' epfileOUT '.p'];
                system(ligne)
                
                fprintf(fid,'%s\n',epfileIN);
                fprintf(fid,'%s\n',epfileOUT);
                
            end
            
        end
        
    end
    
end

fprintf(fid,'\n\n');
fprintf(fid,'!\n');
fclose(fid);

ligne = 'cat "batch.epavgchannel" | epavgchannel';
system(ligne)

system('rm batch.epavgchannel');

