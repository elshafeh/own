clear;

suj_list                                    = dir('../raw/sub*ds');

suj_all                                     = {};

for ns = 1:length(suj_list)
   
    all_parts                               = strsplit(suj_list(ns).name,'_');
    
    suj_name                                = all_parts{1};
    suj_data                                = [all_parts{3}([7 8]) '/' all_parts{3}([5 6]) '/' all_parts{3}([1:4])];
    
    suj_all{ns,1}                           = suj_name;
    suj_all{ns,2}                           = suj_data;
    
    suj_all{ns,3}                           = suj_list(ns).date;
    
    
end

keep suj_all