clear ; clc ;

indx_pt = [];

for a = 1:14   
    for b = 1:3
        suj_list = [1:4 8:17];
        lck = 'CnD' ;
        suj = ['yc' num2str(suj_list(a))] ;
        
        fname_in = [suj '.pt' num2str(b) '.' lck];
        fprintf('Loading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        t = length(data_elan.trial);
        indx = [repmat(a,t,1) repmat(b,t,1) [1:t]'];
        
        indx_pt = [indx_pt;indx];
       
        clearvars -except a b indx_pt
        
    end
end