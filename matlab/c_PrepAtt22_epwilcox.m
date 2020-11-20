addpath(genpath('../../fieldtrip-20151124/'));

%% epwilcox

cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m');

load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);

list_suj = {'yc1' 'yc10' 'yc11' 'yc12' 'yc13' 'yc14' 'yc15' 'yc16' 'yc17' 'yc18' ...
    'yc19' 'yc2' 'yc20' 'yc21' 'yc3' 'yc4' 'yc5' 'yc6' 'yc7' 'yc8' 'yc9'};


data = {'eeg','meg'};
ext = '.lb.p'; 
extOUT = '.lb'; 


for d = 1:length(data) %eeg ou meg
    
    mkdir(['../data/avg_young/erp/' data{d} '/stats']);
    
    for ev = 1:length(event_names) %bp, cue, dis, fdis, target
        
        event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
        mkdir(['../data/avg_young/erp/' data{d} '/stats/' event_names{ev}]);
        
        for cat = 1:length(event_list) % test : cat = 7
            
            if exist(['../data/' list_suj{1} '/erp/' data{d} '/' event_names{ev} '/' list_suj{1} '.pat22.' event_list{cat} ext]) == 2;
                
                FicName   = 'batch.epwilcox';
                fid         = fopen(FicName,'w+');
                fprintf(fid,'#!/bin/bash\n');
                fprintf(fid,'\n');
                fprintf(fid,'epwilcox +fdr<<!\n');
                fprintf(fid,'%d\n',1);
                fprintf(fid,'%d\n',length(list_suj)-1); % pour l'EEG, ne pas prendre en compte yc9 le dernier sujet
                fprintf(fid,'%d\n',0.05); % FDR threshold
                
                
                for sb = 1:length(list_suj)-1 % pour l'EEG, ne pas prendre en compte yc9 le dernier sujet
                    filename = ['../data/' list_suj{sb} '/erp/' data{d} '/' event_names{ev} '/' list_suj{sb} '.pat22.' event_list{cat} ext];
                    fprintf(fid,'%s\n',filename);
                    
                end
                
                
                fileOUT = ['../data/avg_young/erp/' data{d} '/stats/' event_names{ev} '/wilcox.' event_list{cat} extOUT];
                fprintf(fid,'%s\n',fileOUT);
                fprintf(fid,'\n');
                fprintf(fid,'!\n');
                fclose(fid);
                
                system(['chmod 777 ' FicName]);
                system(['bash ' FicName]);
                
            end
        end
    end
end

%% Pour les dis-fdis 

cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m');

load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);


list_suj = {'yc1' 'yc10' 'yc11' 'yc12' 'yc13' 'yc14' 'yc15' 'yc16' 'yc17' 'yc18' ...
    'yc19' 'yc2' 'yc20' 'yc21' 'yc3' 'yc4' 'yc5' 'yc6' 'yc7' 'yc8' 'yc9'};


data = {'eeg','meg'};
ext = '.lb.dis-fdis.p'; 
extOUT = '.lb.dis-fdis'; 


for d = 1:length(data) %eeg ou meg
    
    mkdir(['../data/avg_young/erp/' data{d} '/stats']);
    
    % for ev = 1:length(event_names) %bp, cue, dis, fdis, target
        
        event_list = getfield(event, event_names{4}); %toutes les catégories des dis 
        mkdir(['../data/avg_young/erp/' data{d} '/stats/dis-fdis']);
        
        for cat = 1:length(event_list) 
            
            if exist(['../data/' list_suj{1} '/erp/' data{d} '/dis-fdis/' list_suj{1} '.pat22.' event_list{cat} ext]) == 2;
                
                FicName   = 'batch.epwilcox';
                fid         = fopen(FicName,'w+');
                fprintf(fid,'#!/bin/bash\n');
                fprintf(fid,'\n');
                fprintf(fid,'epwilcox +fdr<<!\n');
                fprintf(fid,'%d\n',1);
                fprintf(fid,'%d\n',length(list_suj)); % length(list_suj)-1 pour l'EEG, ne pas prendre en compte yc9 le dernier sujet
                fprintf(fid,'%d\n',0.05); % FDR threshold
                
                
                for sb = 1:length(list_suj) % length(list_suj)-1 pour l'EEG, ne pas prendre en compte yc9 le dernier sujet
                    filename = ['../data/' list_suj{sb} '/erp/' data{d} '/dis-fdis/' list_suj{sb} '.pat22.' event_list{cat} ext];
                    fprintf(fid,'%s\n',filename);
                    
                end
                
                
                fileOUT = ['../data/avg_young/erp/' data{d} '/stats/dis-fdis/wilcox.' event_list{cat} extOUT];
                fprintf(fid,'%s\n',fileOUT);
                fprintf(fid,'\n');
                fprintf(fid,'!\n');
                fclose(fid);
                
                system(['chmod 777 ' FicName]);
                system(['bash ' FicName]);
                
            end
        end
    % end
end
