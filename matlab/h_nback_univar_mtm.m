function

for nsess = 1:2
    
    fname                       = ['J:/temp/nback/data/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.demean                  = 'yes';
    cfg.baselinewindow          = [-0.1 0];
    data                        = ft_preprocessing(cfg,data);
    
    data                        = rmfield(data,'cfg');
    data_repair                 = megrepair(data); clear data;
    
    avg                         = ft_timelockanalysis([], data_repair);
    avg_comb                    = ft_combineplanar([],avg);
    avg_comb                    = rmfield(avg_comb,'cfg'); clc;
    
    avg_carr{nsess}           	= avg_comb; clear avg_comb;
    data_carr{nsess}            = data_repair; clear data repair;
    
end

data                            = ft_appenddata([],data_carr{:}); clear data_carr;
avg                             = ft_timelockgrandaverage([],avg_carr{:}); clear avg_carr;