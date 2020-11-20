clear;

suj_list     	= [1:4 8:17] ;

for ns = 1:length(suj_list)

    suj       	= ['yc' num2str(suj_list(ns))] ;
    h_virtual_compute_eeg(suj);
    h_virtual_compute_meg(suj);
    
end