clear ;

for ns = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        icounter                                         	= 0;
        data_carrier                                        = {};
        data_index                                      	= [];
        
        fname                                               = ['../data/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(ns) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                                                 = [];
        cfg.demean                                          = 'yes';
        cfg.baselinewindow                                  = [-0.1 0];
        data                                                = ft_preprocessing(cfg,data);
        
        data                                                = rmfield(data,'cfg');
        data_repair                                         = megrepair(data);
        
        avg                                                 = ft_timelockanalysis([], data_repair);
        avg_comb                                            = ft_combineplanar([],avg);
        avg_comb                                            = rmfield(avg_comb,'cfg'); clc;
        
        fname_out                                           = ['../data/erf/data_sess' num2str(nsess) '_s' num2str(ns) '_erfComb.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'avg_comb','-v7.3');toc
        
    end
end