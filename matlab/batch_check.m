function batch_check(suj,ext_file,ext_check)

FicName=[suj '.' ext_file '.' ext_check '.avg.batch'];

fid = fopen(FicName,'w+');

epIN = {'tempo.1101','tempo.1103','tempo.1202','tempo.1204','tempo.1001','tempo.1003','tempo.1002','tempo.1004'};

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');

fprintf(fid,'epavg<< !\n');

fprintf(fid,'%s\n',[suj '.CnD.' ext_file '.' ext_check]);
fprintf(fid,'\n');

for s = 1:length(epIN)  
    fprintf(fid,'%s\n',epIN{s});    
end

fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,'!\n');

fclose(fid);

system(['chmod 777 ' FicName]);
system(['bash ' FicName]);
