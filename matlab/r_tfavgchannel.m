function r_tfavgchannel(event,cond,channels,fwin,suffixe,list_ctl,list_mig)

list_suj = {list_ctl{:} list_mig{:}};

%fwin : fenetre des frequences, [7 12] par ex.
%suffixe: nom du groupe d'électrodes à rajouter en fin de fichiers
system('rm batch.epavgchannel');

FicName     = ['batch.epavgchannel'];
fid         = fopen(FicName,'w+');
fprintf(fid,'%d\n',1);
fprintf(fid,'%d\n',length(channels));

for ch = 1:length(channels)
    
    fprintf(fid,'%d\n',channels(ch))
    
end

for sb=1:length(list_suj)
    
    suj = list_suj{sb};
    
    epfileIN  = ['../data/' suj '/tf/' event '/' suj '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
    epfileOUT = [epfileIN '.' suffixe];
    
    ligne = ['rm ' epfileOUT '.p'];
    system(ligne)
    
    fprintf(fid,'%s\n',epfileIN);
    fprintf(fid,'%s\n',epfileOUT);
    
end


fprintf(fid,'\n\n');
fprintf(fid,'!\n');
fclose(fid);

ligne = 'cat "batch.epavgchannel" | epavgchannel';
system(ligne)

system('rm batch.epavgchannel');

%% group average erp

%ctl
FicName2    = 'ERP.list';
fid        = fopen(FicName2,'w+');

epfileOUT   = ['../data/avg_mig/tf/' event '/ctl.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb.' suffixe];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n\n',epfileOUT);

for sb = 1:length(list_ctl)
    
    epfileIN = ['../data/' list_ctl{sb} '/tf/' event '/' list_ctl{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb.' suffixe];
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

epfileOUT   = ['../data/avg_mig/tf/' event '/mig.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb.' suffixe];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n\n',epfileOUT);

for sb = 1:length(list_mig)
    
    epfileIN = ['../data/' list_mig{sb} '/tf/' event '/' list_mig{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb.' suffixe];
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

epfileOUT   = ['../data/avg_mig/tf/' event '/ctl.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.median.lb.' suffixe];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n',num2str(length(list_ctl)))

for sb = 1:length(list_ctl)
    
    epfileIN = ['../data/' list_ctl{sb} '/tf/' event '/' list_ctl{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb.' suffixe];
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

epfileOUT   = ['../data/avg_mig/tf/' event '/mig.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.median.lb.' suffixe];
system(['rm ' epfileOUT '.p'])

fprintf(fid,'%s\n',num2str(length(list_mig)))

for sb = 1:length(list_mig)
    
    epfileIN = ['../data/' list_mig{sb} '/tf/' event '/' list_mig{sb} '.pat22.' cond '.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb.' suffixe];
    fprintf(fid,'%s\n',epfileIN);
    
end

fprintf(fid,'%s\n\n',epfileOUT);
fprintf(fid,'%s\n\n','');
fprintf(fid,'%s','!');
fclose(fid);

ligne = 'epmedian <ERP.list';
system(ligne)
system('rm ERP.list')

%%
end