function r_restingstate_eegspectrum()

suj_list = {'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};

meeg     = {'meg','eeg'};

for sb = 1:length(suj_list)
    
    for d = 1:length(meeg)
        
        suj  = suj_list{sb};
        data = meeg{d};
        
        cd(['../data/' suj '/meeg'])
        system('rm batch*');
        
        EEGfileIN = [suj '.restingstate.meeg.swap'];
        PARfile   = ['../../../par/' data '.eegspectrum.par'];
        POSfile   = ['../pos/' suj '.restingstate.pos'];
        
        ligne     = ['eegspectrum ' EEGfileIN  ' ' PARfile ' ' POSfile];
        
        system(ligne)
        
        %lissage du spectre
        
        window      = 1; %lissage sur fenêtre de 1 Hz
        epfileIN    = ['restingstate_' data '_spectrum.253'];
        epfileOUT   = [epfileIN '.s' num2str(window)];
        system(['rm ' epfileOUT '.p'])
        
        FicName     = 'batch.epsmooth';
        fid         = fopen(FicName,'w+');
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,'\n');
        fprintf(fid,'epsmooth<<!\n');
        fprintf(fid,'%d\n',window);
        fprintf(fid,'%d\n',0);
        fprintf(fid,'%s\n',epfileIN);
        fprintf(fid,'%s\n',epfileOUT);
        fprintf(fid,'\n');
        fprintf(fid,'!\n');
        fclose(fid);
        
        system(['chmod 777 ' FicName]);
        system(['bash ' FicName]);
        
        system('rm batch.epsmooth');
        system(['rm restingstate_' data '_spectrum.253.p'])
        
        % GFP
        
        epfileIN  = epfileOUT;
        epfileOUT = [epfileIN '.gfp'];
        
        ligne = ['rm ' epfileOUT '.p']
        system(ligne)
        
        FicName     = 'batch.eprms';
        fid         = fopen(FicName,'w+');
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,'\n');
        fprintf(fid,'eprms<<!\n');
        fprintf(fid,'%d\n',0);
        fprintf(fid,'%s\n',epfileIN);
        fprintf(fid,'%s\n',epfileOUT);
        fprintf(fid,'\n');
        fprintf(fid,'!\n');
        fclose(fid);
        
        system(['chmod 777 ' FicName]);
        system(['bash ' FicName]);
        
        system('rm batch.eprms');
                
        
        cd ../../../scripts.m
        
    end
    
end
