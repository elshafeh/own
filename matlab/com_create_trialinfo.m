clear ; close all;

suj_list                        = [1:4 8:17];

for ns = 1:length(suj_list)
    
    fname                       = ['/Volumes/heshamshung/alpha_compare/lcmv/yc' num2str(suj_list(ns)) '.CnD.com90roi.meg.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    index                       = data.trialinfo;
    
    save(['/Volumes/heshamshung/alpha_compare/trialinfo/yc' num2str(suj_list(ns)) '.CnD.trialinfo.mat'],'index');
    
    clear index data
    
end