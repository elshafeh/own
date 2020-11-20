clear;

suj_list                                    = dir('../data/sub*/preproc/*finalrej_trialinfo.mat');

for ns = 1:length(suj_list)
    
    load([suj_list(ns).folder '/' suj_list(ns).name]);
    
    index                                   = trialinfo;
    
    save([suj_list(ns).folder '/' suj_list(ns).name],'index');
    
    
end