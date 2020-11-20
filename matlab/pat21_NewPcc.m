clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    for prt = 1:3
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))] ;
        fname_in    = [suj '.pt' num2str(prt) '.CnD'];
        
        fprintf('Loading %50s\n',fname_in);
        
        load(['../data/elan/' fname_in '.mat'])
        
        data_in  = data_elan ;
        
        clear data_elan
        
        h_pccSeparate(suj,prt,data_in,[-0.6 -0.5 0.9],0.3,0,13,3);

    end
end