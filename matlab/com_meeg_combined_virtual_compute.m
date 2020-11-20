clear;

suj_list                                                = [1:4 8:17] ;

for ns = 1:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(ns))];
    [leadfield,combined_vol,combined_ses]               = h_compute_meeg_leadfield(suj);
    
    
end