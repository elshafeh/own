function r_TFtimeprofile(event,cond,fwin,blwin,list_ctl,list_mig)

list_suj = {list_ctl{:} list_mig{:}};


FicName     = 'TF.list';
fid         = fopen(FicName,'w+');
fprintf(fid,'%s\n','y');
fprintf(fid,'%s\n',num2str(fwin(1))); %fréquence basse
fprintf(fid,'%s\n',num2str(fwin(2))); %fréquence haute
fprintf(fid,'%s\n','50'); %troncature
fprintf(fid,'%s\n','1'); %baseline moyenne
fprintf(fid,'%s\n',num2str(blwin(1))); %debut baseline
fprintf(fid,'%s\n',num2str(blwin(2))); %fin baseline
fprintf(fid,'%s\n','1'); %substract baseline
fprintf(fid,'%s\n','1'); %average over frequencies


for sb = 1:length(list_suj)
    
    tffileIN  = ['../data/' list_suj{sb} '/tf/' event '/' list_suj{sb} '.pat22.' cond '.avg.tf'];
    tffileOUT = ['../data/' list_suj{sb} '/tf/' event '/' list_suj{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
    
    system(['rm ' tffileOUT '.p'])
    
    fprintf(fid,'%s\n',tffileIN);
    fprintf(fid,'%s\n',tffileOUT);
    
end

fprintf(fid,'%s\n\n','');
fprintf(fid,'%s','!');
fclose(fid);

ligne = 'tfavgprofilet <TF.list';
system(ligne)
system('rm TF.list')

%% group average erp

%ctl
FicName2    = 'ERP.list';
fid        = fopen(FicName2,'w+');

epfileOUT   = ['../data/avg_mig/tf/' event '/ctl.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n\n',epfileOUT);

for sb = 1:length(list_ctl)
    
    epfileIN = ['../data/' list_ctl{sb} '/tf/' event '/' list_ctl{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
    fprintf(fid,'%s\n',epfileIN)
    
end 

fprintf(fid,'%s\n\n','');
fprintf(fid,'%s','!');
fclose(fid);

ligne = 'epavg <ERP.list';
system(ligne)
system('rm ERP.list')

%mig
FicName2    = 'ERP.list';
fid        = fopen(FicName2,'w+');

epfileOUT   = ['../data/avg_mig/tf/' event '/mig.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n\n',epfileOUT);

for sb = 1:length(list_mig)
    
    epfileIN = ['../data/' list_mig{sb} '/tf/' event '/' list_mig{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
    fprintf(fid,'%s\n',epfileIN);
    
end 

fprintf(fid,'%s\n\n','');
fprintf(fid,'%s','!');
fclose(fid);

ligne = 'epavg <ERP.list';
system(ligne)
system('rm ERP.list')

%% group median erp

%ctl
FicName2    = 'ERP.list';
fid        = fopen(FicName2,'w+');

epfileOUT   = ['../data/avg_mig/tf/' event '/ctl.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) 'median.lb'];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n',num2str(length(list_ctl)))

for sb = 1:length(list_ctl)
    
    epfileIN = ['../data/' list_ctl{sb} '/tf/' event '/' list_ctl{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
    fprintf(fid,'%s\n',epfileIN)
    
end

fprintf(fid,'%s\n\n',epfileOUT);
fprintf(fid,'%s\n\n','');
fprintf(fid,'%s','!');
fclose(fid);

ligne = 'epmedian <ERP.list';
system(ligne)
system('rm ERP.list')

%mig
FicName2    = 'ERP.list';
fid        = fopen(FicName2,'w+');

epfileOUT   = ['../data/avg_mig/tf/' event '/mig.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.median.lb'];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n',num2str(length(list_mig)))

for sb = 1:length(list_mig)
    
    epfileIN = ['../data/' list_mig{sb} '/tf/' event '/' list_mig{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
    fprintf(fid,'%s\n',epfileIN);
    
end

fprintf(fid,'%s\n\n',epfileOUT);
fprintf(fid,'%s\n\n','');
fprintf(fid,'%s','!');
fclose(fid);

ligne = 'epmedian <ERP.list';
system(ligne)
system('rm ERP.list')

end

        
        
        