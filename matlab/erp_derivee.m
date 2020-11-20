function [entete,xe,data2,util] = erp_derivee(filename,smooth)

addpath('/dycog/Aurelie/DATA/mat_prog/ELAN/erp');

[filepath,name,ext] = fileparts(filename);
cd(filepath)

%% lissage

r_PrepAtt_epsmooth(name,smooth)

%% derivation

[entete,xe,data,util] = readpem([name '.s' num2str(smooth) ext]);

for v = 1:util.nbvoies
    
    for ech = 1:util.nbech
        
        if ech == 1
            
            data2(ech,v) = (data(ech+1,v)-data(ech,v))/2;
            
        elseif ech == util.nbech
            
            data2(ech,v) = (data(ech,v)-data(ech-1,v))/2;
            
        else
            
            data2(ech,v) = (data(ech+1,v)-data(ech-1,v))/2;
            
        end
        
    end
    
end
          
writepem(entete,xe,data2,[name '.deriv' ext])    

system(['rm ' name '.s' num2str(smooth) ext])


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

end