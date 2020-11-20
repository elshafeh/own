% verify that data from different parts have different gradiotmeter
% information

clear;clc;

suj_list = [1:4 8:17];

for s = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(s))];
    
    for p = 1:3
        
        fprintf('Loading %20s\n',[suj '.pat2.NDIS.pt' num2str(p) '.mat'])
        
        load(['../data/' suj '/elan/' suj '.pat2.NDIS.pt' num2str(p) '.mat']);
        
        carr_pos{p} = [ data_elan.hdr.orig.hc.standard;data_elan.hdr.orig.hc.dewar;data_elan.hdr.orig.hc.head]; % data_elan.hdr.orig.hc.dewar;
    end
    
    mtch = [1 2 ; 1 3; 2 3];
    
    for p = 1:size(mtch,1);
        
        if isequal(carr_pos{mtch(p,1)},carr_pos{mtch(p,2)})    
            fprintf('For %4s : Block %1d and Block %1d have the same hc!\n',suj, mtch(p,1),mtch(p,2));
        else
            fprintf('For %4s : Block %1d and Block %1d dont have the same hc!\n',suj, mtch(p,1),mtch(p,2));
        end
        
    end
    
end