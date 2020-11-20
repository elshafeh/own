list_mig    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
list_ctl    = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};
suj    = [list_ctl list_mig];

data        = {'eeg' 'meg'};

for sb = 1:length(suj)
    
    for d = 1:length(data)
                       
        for event = {'target'} %{'target','cue','dis','fdis'}
            
            if strcmp(event,'target')
                cond = 'nDT';
            elseif strcmp(event,'cue')
                cond = 'CnD';
            elseif strcmp(event,'fdis')
                cond = 'fDIS';
            elseif strcmp(event,'dis')
                cond = 'DIS';
            end
            
            cd(['../data/' suj{sb} '/erp/' data{d} '/' event{:}])
            
            %Average of the two halves
            FicName     = 'ERP.list';
            fid         = fopen(FicName,'w+');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'\n');
            fprintf(fid,'epavg<<!\n');
            
            for b = 1:10
                
                epfileOUT   = [suj{sb} '.pat22.' cond '.b' num2str(b)];
                system(['rm ' epfileOUT '.p'])
                fprintf(fid,'%s\n\n',epfileOUT);
                
                for h = 1:2
                    
                    epfileIN = [suj{sb} '.pat22.' cond '.b' num2str(b) 'half' num2str(h)];
                    fprintf(fid,'%s\n',epfileIN);
                    
                end
                
                fprintf(fid,'\n');
                
            end
            fprintf(fid,'\n');
            fprintf(fid,'%s','!');
            fclose(fid);
            
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
            system('rm ERP.list')
            
            cd ../../../../../scripts.m
            
        end
        
    end
    
end

