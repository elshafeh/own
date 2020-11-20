
addpath(genpath('../../fieldtrip-20151124/'));

%% average MEG ERF

load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);

list_suj = {'yc1' 'yc10' 'yc11' 'yc12' 'yc13' 'yc14' 'yc15' 'yc16' 'yc17' 'yc18' ...
    'yc19' 'yc2' 'yc20' 'yc21' 'yc3' 'yc4' 'yc5' 'yc6' 'yc7' 'yc8' 'yc9'};

ext = '.lb.gfp'; % le gfp n'a pas été fait sur les PE des fdis. 
%ext = '.lb'; % pour voir les GA sur tous les capteurs 
data = 'meg';

% mkdir('../data/avg_young/');
% mkdir('../data/avg_young/erp');
% mkdir(['../data/avg_young/erp/' data]);

for ev = 5 %1:length(event_names) %bp, cue, dis, fdis, target
    
    event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
    mkdir(['../data/avg_young/erp/' data '/' event_names{ev}]);
    
    for cat = 1:length(event_list)
        
        if exist(['../data/' list_suj{1} '/erp/' data '/' event_names{ev} '/' list_suj{1} '.pat22.' event_list{cat} ext '.p']) == 2;
            
            cd(['../data/avg_young/erp/' data '/' event_names{ev}])
            
            system(['rm young.pat22.' event_list{cat} ext '.p'])
            system('rm ERP.list')
            
            FicName     = 'ERP.list';
            fid         = fopen(FicName,'w+');
            epfileOUT   = ['young.pat22.' event_list{cat} ext];
            fprintf(fid,'%s\n\n',epfileOUT);
            
            for sb = 1:length(list_suj)
                suj      = list_suj{sb};
                epfileIN = [ '../../../../' suj '/erp/' data '/' event_names{ev} '/' suj '.pat22.' event_list{cat} ext ];
                fprintf(fid,'%s\n',epfileIN);
            end
            
            fprintf(fid,'%s\n\n','');
            fprintf(fid,'%s','!');
            fclose(fid);
            
            ligne = 'epavg <ERP.list';
            system(ligne)
            system('rm ERP.list')
            
            cd ../../../../../scripts.m
            
        end
        
    end
    
end

%% average EEG ERP

load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);

% list_suj = {'yc1' 'yc10' 'yc11' 'yc12' 'yc13' 'yc14' 'yc15' 'yc16' 'yc17' 'yc18' ...
%     'yc19' 'yc2' 'yc20' 'yc21' 'yc3' 'yc4' 'yc5' 'yc6' 'yc7' 'yc8' 'yc9'};

list_suj = {'yc1' 'yc10' 'yc12' 'yc13' 'yc14' 'yc15' 'yc16' 'yc17' 'yc18' ...
    'yc19' 'yc2' 'yc20' 'yc21' 'yc3' 'yc4' 'yc5' 'yc6' 'yc7' 'yc8'}; % on a enlevé yc11 qui a un EEG non exploitable, et yc9 qui n'a pas d'EEG. 

ext = '.lb'; 
data = 'eeg';

% mkdir('../data/avg_young/');
% mkdir('../data/avg_young/erp');
% mkdir(['../data/avg_young/erp/' data]);

for ev = 1:length(event_names) %bp, cue, dis, fdis, target
    
    event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
    mkdir(['../data/avg_young/erp/' data '/' event_names{ev}]);
    
    for cat = 1:length(event_list)
        
        if exist(['../data/' list_suj{1} '/erp/' data '/' event_names{ev} '/' list_suj{1} '.pat22.' event_list{cat} ext '.p']) == 2;
            
            cd(['../data/avg_young/erp/' data '/' event_names{ev}])
            
            system(['rm young.pat22.' event_list{cat} ext '.p'])
            system('rm ERP.list')
            
            FicName     = 'ERP.list';
            fid         = fopen(FicName,'w+');
            epfileOUT   = ['young.pat22.' event_list{cat} ext];
            fprintf(fid,'%s\n\n',epfileOUT);
            
            for sb = 1:length(list_suj)
                suj      = list_suj{sb};
                epfileIN = [ '../../../../' suj '/erp/' data '/' event_names{ev} '/' suj '.pat22.' event_list{cat} ext ];
                fprintf(fid,'%s\n',epfileIN);
            end
            
            fprintf(fid,'%s\n\n','');
            fprintf(fid,'%s','!');
            fclose(fid);
            
            ligne = 'epavg <ERP.list';
            system(ligne)
            system('rm ERP.list')
            
            cd ../../../../../scripts.m
            
        end
        
    end
    
end

