clear ; clc ; close all;


% median TF -> groups

list_mig    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
list_ctl    = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};
load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);
extIN       = '.avg.tf';
extOUT      = '.med.tf';

data = 'meg';

mkdir('../data/avg_mig/');
mkdir('../data/avg_mig/tf');

for ev = 1:length(event_names) %bp, cue, dis, fdis, target
    
    event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
    mkdir(['../data/avg_mig/tf/' event_names{ev}]);
    
    for cat = 1:length(event_list)
        
        if exist(['../data/' list_ctl{1} '/tf/' event_names{ev} '/' list_ctl{1} '.pat22.' event_list{cat} extIN]) == 2;
            
            cd(['../data/avg_mig/tf/' event_names{ev}])
            
            system(['rm ctl.pat22.' event_list{cat} extOUT ])
            system(['rm mig.pat22.' event_list{cat} extOUT ])
            system('rm TF.list')
            
            %%ctl
            FicName     = 'TF.list';
            fid         = fopen(FicName,'w+');
            tffileOUT   = ['ctl.pat22.' event_list{cat} extOUT];
            
            fprintf(fid,'%s\n',num2str(length(list_ctl))); %nombre de sujets
            fprintf(fid,'%s\n','0') %  pas de baseline 
                                
            for sb = 1:length(list_ctl)
                suj      = list_ctl{sb};
                tffileIN = [ '../../../' suj '/tf/' event_names{ev} '/' suj '.pat22.' event_list{cat} extIN ];
                fprintf(fid,'%s\n',tffileIN);
            end
            
            fprintf(fid,'%s\n\n',tffileOUT);
            fprintf(fid,'%s\n\n','');
            fprintf(fid,'%s','!');
            fclose(fid);
            
            ligne = 'tfavgmedian <TF.list';
            system(ligne)
            system('rm TF.list')
            
            %%mig
            FicName     = 'TF.list';
            fid         = fopen(FicName,'w+');
            tffileOUT   = ['mig.pat22.' event_list{cat} extOUT];
            
            fprintf(fid,'%s\n',num2str(length(list_mig))); %nombre de sujets
            fprintf(fid,'%s\n','0') %  pas de baseline 
            
            for sb = 1:length(list_mig)
                suj      = list_mig{sb};
                tffileIN = [ '../../../' suj '/tf/' event_names{ev} '/' suj '.pat22.' event_list{cat} extIN ];
                fprintf(fid,'%s\n',tffileIN);
            end
            
            fprintf(fid,'%s\n\n',tffileOUT);
            fprintf(fid,'%s\n\n','');
            fprintf(fid,'%s','!');
            fclose(fid);
            
            ligne = 'tfavgmedian <TF.list';
            system(ligne)
            system('rm TF.list')
            
            
            cd ../../../../scripts.m
            
        end
        
    end
    
end

