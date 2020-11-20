clear;

suj_list                = [1:4 8:17] ;

for ns = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(ns))] ;
    cond_main           = 'CnD.com90roi.meg';
    
    fname               = ['/Volumes/h128ssd/alpha_compare/lcmv/' suj '.' cond_main '.mat'];
    fprintf('Loading %s\n\n',fname);
    load(fname);
    
    data                = rmfield(data,'cfg');
    
    fprintf('Saving %s\n\n',fname);
    save(fname,'data','-v7.3');
    
end