%% average MEG ERF

list_mig    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
% list_ctl    = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
%     'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'}; MEG
list_ctl    = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
   'uc1' 'uc4'  'yc5' 'yc20' 'yc21' 'yc16' 'yc18' 'yc4'}

load ../documents/event.mat; %structure 'event'
event_names = fieldnames(event);
ext         = '.lb.dis-fdis.V-N';


data = 'eeg';

mkdir('../data/avg_mig/');
mkdir('../data/avg_mig/erp');
mkdir(['../data/avg_mig/erp/' data]);

ev = 4; %dis

event_list = getfield(event, event_names{ev}); %toutes les catégories (ex. CnD CD1 CD2...)
mkdir(['../data/avg_mig/erp/' data '/dis-fdis']);

for cat = 1:length(event_list)
    
    if exist(['../data/' list_ctl{1} '/erp/' data '/dis-fdis/' list_ctl{1} '.pat22.' event_list{cat} ext '.p']) == 2;
        
        cd(['../data/avg_mig/erp/' data '/dis-fdis'])
        
        system(['rm ctl.pat22.' event_list{cat} ext '.p'])
        system(['rm mig.pat22.' event_list{cat} ext '.p'])
        system('rm ERP.list')
        
        %%ctl
        FicName     = 'ERP.list';
        fid         = fopen(FicName,'w+');
        epfileOUT   = ['ctl.pat22.' event_list{cat} ext];
        fprintf(fid,'%s\n\n',epfileOUT);
        
        for sb = 1:length(list_ctl)
            suj      = list_ctl{sb};
            epfileIN = [ '../../../../' suj '/erp/' data '/dis-fdis/' suj '.pat22.' event_list{cat} ext ];
            fprintf(fid,'%s\n',epfileIN);
        end
        
        fprintf(fid,'%s\n\n','');
        fprintf(fid,'%s','!');
        fclose(fid);
        
        ligne = 'epavg <ERP.list';
        system(ligne)
        system('rm ERP.list')
        
        %%mig
        FicName     = 'ERP.list';
        fid         = fopen(FicName,'w+');
        epfileOUT   = ['mig.pat22.' event_list{cat} ext];
        fprintf(fid,'%s\n\n',epfileOUT);
        
        for sb = 1:length(list_mig)
            suj      = list_mig{sb};
            epfileIN = [ '../../../../' suj '/erp/' data '/dis-fdis/' suj '.pat22.' event_list{cat} ext ];
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


