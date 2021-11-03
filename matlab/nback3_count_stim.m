clear;clc;

suj_list                        = [1:33 35:36 38:44 46:51];
allcount                        = [];

for nsuj = 1:length(suj_list)
    
    sujname                     = ['sub' num2str(suj_list(nsuj))];
    
    for nstim = 1:10
        
        
        dir_files               = '~/Dropbox/project_me/data/nback/';
        fname                   = [dir_files 'auc/' sujname '.decoding.stim' num2str(nstim) '.nodemean.leaveone.mat'];
        
        allcount(nsuj,nstim)    = length(dir(fname));
        
    end
end

keep allcount

sum(allcount);