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