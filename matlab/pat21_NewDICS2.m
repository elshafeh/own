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
        
        fprintf('\nLoading Leadfield\n');
        load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
        load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
        
        list_filt   = 'DISfDIS.7t15Hz.m200p800';
        
        fex_comblex.st_point    = [0.4 0.4];
        fex_comblex.tm_win      = [0.3 0.3];
        fex_comblex.f_focus     = [9 13];
        fex_comblex.formul      = [1 1];
        fex_comblex.trilili     = [0.015 0];
        fex_comblex.tap         = [3 3];
        
        for ix = 1:length(fex_comblex.st_point)
            
            h_dicsSeparate(suj,prt,data_in,list_load, ...
                fex_comblex.st_point(ix), ...
                fex_comblex.tm_win(ix), ...
                fex_comblex.trilili(ix), ...
                fex_comblex.f_focus(ix), ...
                fex_comblex.tap(ix), ...
                fex_comblex.formul(ix), ...
                list_filt,leadfield,vol);
            
        end
        
        clear data_in
        
    end
    
end