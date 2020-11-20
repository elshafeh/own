clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    flist       = {'7t11Hz','11t15Hz'};
    tlist       = {'m600m200','p200p600','p600p1000','p1400p1800'};
    
    for f = 1:length(flist)
        for t = 1:length(tlist)
            
            for n_prt = 1:3
                
                fname_in = ['../data/all_data/' suj '.pt' num2str(n_prt) '.CnD.' tlist{t} '.' flist{f} '.PCCSource1cm.mat'];
                fprintf('Loading %s\n',fname_in)
                load(fname_in)
                
                cfg                   = [];
                cfg.method            = 'plv';
                source_plv            = ft_connectivityanalysis(cfg, source);
                
                save(fname_in,'source','source_plv','source_conn','network_full','-v7.3');
                
            end
        end
    end
end