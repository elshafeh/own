 % check trial number


clear; clc ;

fin = '../txt/lr.ntrials.txt';
fid = fopen(fin,'W+');

for a = [1:4 8:17]
    
    suj = ['yc' num2str(a)];
    
    cond = {'RCnD','LCnD'};
    
    fprintf(fid,'%4s\t',suj);
    
    for c = 1:2
        
        for b = 1:3
            
            fname = [suj '.pt' num2str(b) '.' cond{c} '.mat'];
            fprintf('Loading %30s\n',fname);
            load(['../data/' suj '/elan/' fname]);
            
            fprintf(fid,'%3d\t',length(data_elan.trial));
            
            clear data_elan
            
        end
        
    end
    
    fprintf(fid,'\n');
    
end

fclose(fid);