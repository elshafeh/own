%%%Réalise une ANOVA sur chaque point du .p après un lissage 

grp1 = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
grp2 = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc21' 'yc16' 'yc18' 'yc4'};
%grp2 = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
%    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};
%    %%pour MEG
tab = {grp1;grp2};

condname = 'dis';
data     = 'eeg';
ext      = '.lb.avgelec';
cond     = 'DIS1';
window   = 15; %facteur de lissage (15 pour DIS et target, 50 pour cue)

addpath('/dycog/Aurelie/DATA/mat_prog/stat/rm-ANOVA-1within1betweenFactors');
addpath('/dycog/Aurelie/DATA/mat_prog/ELAN/erp');

dirout = ['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/avg_mig/erp/' data '/stats/'];
mkdir(dirout);

disp('Calcul en cours...')


FicName   = 'batch.epkruskal';
fid         = fopen(FicName,'w+');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');
fprintf(fid,'epkruskal<<!\n');
fprintf(fid,'%d\n',2);
fprintf(fid,'%d\n',length(grp1));
fprintf(fid,'%d\n',length(grp2));

for grp=1:2;    %ctl ou mig
    
    for i=1:length(tab{grp}); %on passe tous les sujets
        
        eval(['filenamePRE = ''' '../data/' tab{grp}{i} '/erp/' data '/' condname ...
            '/' tab{grp}{i} '.pat22.' cond ext ''';']); %sans l'extension .p
        
        r_PrepAtt_epsmooth(filenamePRE, window) %lissage
        
        filename = [filenamePRE '.s' num2str(window) '.p'];
        fprintf(fid,'%s\n',filename);
    end
    
end


fileOUT = [dirout 'kruskal.' cond ext];
fprintf(fid,'%s\n',fileOUT);
fprintf(fid,'\n');
fprintf(fid,'!\n');
fclose(fid);

system(['chmod 777 ' FicName]);
system(['bash ' FicName]);

%system('rm batch.epkruskal');

disp('Calcul terminé.');

function r_PrepAtt_epsmooth(epfileIN, window) %sans .p

epfileOUT   = [epfileIN '.s' num2str(window)];
system(['rm ' epfileOUT '.p'])

FicName     = ['batch.epsmooth'];
fid         = fopen(FicName,'w+');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');
fprintf(fid,'epsmooth<<!\n');
fprintf(fid,'%d\n',window);
fprintf(fid,'%d\n',-500);
fprintf(fid,'%s\n',epfileIN);
fprintf(fid,'%s\n',epfileOUT);
fprintf(fid,'\n');
fprintf(fid,'!\n');
fclose(fid);

system(['chmod 777 ' FicName]);
system(['bash ' FicName]);

system('rm batch.epsmooth');

end





