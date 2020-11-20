clear ; clc ; close all;

list_all_suj = {'oc12'};
data         = {'eeg'};

load ../documents/event.mat;
event_names = fieldnames(event);

for sb=1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    
    system(['rm -r /dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj])
    
    for d = 1:length(data)
        
        list_file{1} = '/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/oc12/meeg/oc12.pat22.3rdOrder.jc.offset.meeg.bs47t53.o3.bs97t103.o3.bs147t153.o3.bp0point1t40.o3.OnlyEEG.icacorrMEG.regress0.eeg';
        list_file{2} = '/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/oc12/meeg/oc12.pat22.3rdOrder.jc.offset.meeg.bs47t53.o3.bs97t103.o3.bs147t153.o3.bp0point1t40.o3.OnlyEEG.icacorrMEG.eeg';
        list_file{3} = '/dycog/commun/manu/oc12.pat22.3rdOrder.jc.offset.meeg.bs47t53.o3.bs97t103.o3.bs147t153.o3.bp0point1t40.o3.OnlyEEG.icacorrMEG.ASR.eeg';
        
        list_ext     = {'reg','noreg','asr'};
        
        for nfile = 1:length(list_file)
            
            mkdir(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/tempo']);
            mkdir(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/cue']);
            mkdir(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/dis']);
            mkdir(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/target']);
            mkdir(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/fdis']);
            mkdir(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/bp']);
            
            cd(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/tempo']);
            
            EEGfile     = list_file{nfile};
            
            posfileIN   = ['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
            
            parfile     = ['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/par/eegavg-' data{d} '.par'];
            
            posfileOUT  = [ suj '.tmp.pos'];
            
            ligne = ['eegavg ' EEGfile ' ' posfileIN ' ' parfile ' ' posfileOUT ' +norejection'];
            system(ligne)
            
            ligne = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/bash_auto-epavg ' suj]; %on reprend le script bash d'avant
            
            system(ligne);
            
            for ev = 1:length(event_names)
                
                cd(['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/manu_correction/' suj '/erp/' data{d} '_' list_ext{nfile} '/' event_names{ev}]);
                event_list = getfield(event, event_names{ev});
                
                for cat = 1:length(event_list)
                    
                    epfileIN    = [suj '.pat22.' event_list{cat}];
                    epfileOUT   = [epfileIN '.' list_ext{nfile} '.lb'];
                    
                    ligne       = ['rm ' epfileOUT '.p'];
                    system(ligne)
                    
                    FicName     = 'batch.epbline';
                    fid         = fopen(FicName,'w+');
                    fprintf(fid,'#!/bin/bash\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'epbline<<!\n');
                    fprintf(fid,'%s\n',epfileIN);
                    fprintf(fid,'%s\n',epfileIN);
                    fprintf(fid,'%s\n',epfileOUT);
                    fprintf(fid,'%d\n',-100);
                    fprintf(fid,'%d\n',0);
                    fprintf(fid,'\n');
                    fprintf(fid,'!\n');
                    fclose(fid);
                    
                    system(['chmod 777 ' FicName]);
                    system(['bash ' FicName]);
                    
                    system('rm batch.epbline');
                    
                end                
            end
            
            cd /mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m
            
        end
    end
end

