clear;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        fname                   = ['../data/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        % remove trials with button-press
        cfg                     = [];
        cfg.trials              = find(data.trialinfo(:,4) == 0);
        data                    = ft_selectdata(cfg,data);
        
        data_repair{nsess}      = megrepair(data); clear data;
        
    end
    
    data                        = ft_appenddata([],data_repair{:});
    h_mtm_compute(data,nsuj,12,-1.5:0.03:1.5,1:30,10,'4peak');
    
end