clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    for prt = 1:3
        
        suj_list = [1:4 8:17];
        
        list_load = {'DIS','fDIS'};
        suj = ['yc' num2str(suj_list(sb))] ;
        
        for cd = 1:2
            fname_in = [suj '.pt' num2str(prt) '.' list_load{cd}];
            fprintf('Loading %50s\n',fname_in);
            load(['../data/elan/' fname_in '.mat'])
            data_in{cd} = data_elan ; clear data_elan ;
        end
        
        list_cond = {'DIS','fDIS'};
        
        fexcomblex = [0.1 0.4 5 1 0 2
        0.3 0.3 35  5 0.01/2  10];
        
        list_filt   = {'DISfDIS.3t9Hz','DISfDIS.30t50Hz'};

        for ix = 1:size(fexcomblex,1)
            h_dicsSeparate(suj,prt,data_in,list_cond,fexcomblex(ix,1),fexcomblex(ix,2) ...
                ,fexcomblex(ix,5),fexcomblex(ix,3),fexcomblex(ix,6), ...
                fexcomblex(ix,4),list_filt{ix});
        end
        
        clear data_in
        
    end
end