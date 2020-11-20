clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    for nsess = 1:2
        
        fname                                               = ['../data/stacked/data_sess' num2str(nsess) '_s' num2str(nsuj) '_3stacked.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        data_repair                                         = megrepair(data);
        h_mtm_compute(data_repair,nsuj,nsess);
        
        keep nsess nsuj
        
    end
end