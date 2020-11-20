clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    for nsess = 1:2
        
        chk                                                     = [];
        
        if length(chk) < 3 % 3conditions per session (2 backs + all)
            
            fname                                               = ['J:/temp/nback/data/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
            fprintf('\nloading %s\n',fname);
            load(fname);
            
            data_repair                                         = megrepair(data);
            
            h_mtm_compute(data_repair,nsuj,nsess,-1.5:0.02:2,[1:1:30 32:2:100],'sens');
            
            keep nsess nsuj
            
        end
        
    end
end