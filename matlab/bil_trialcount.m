clear ;

suj_list                        = dir('../data/sub*');
trialcount                      = [];

for sb = 1:length(suj_list)
    
    subjectName                 = suj_list(sb).name;
    dir_data                    = ['../data/' subjectName '/preproc/'];
    
    fname                       = [dir_data subjectName '_allTrialInfo.mat']; load(fname);
    trialcount(sb,1)            = length(index);
    
    fname                       = [dir_data subjectName '_firstCueLock_ICAlean_finalrej.mat'];load(fname);
    
end