clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    for nsess = [1 2]
        
        fname                       = ['J:/temp/nback/data/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        orig_data                   = data;
        data_repair             	= megrepair(data); clear data;
        
        time_width                  = 0.02;
        freq_width                  = 2;
        
        time_list                   = -0.5:time_width:2;
        freq_list                   = 1:freq_width:100;
        
        cfg                         = [] ;
        cfg.output                  = 'pow';        cfg.method        	= 'mtmconvol';
        cfg.keeptrials              = 'yes';        cfg.taper        	= 'hanning';
        cfg.pad                     = 'nextpow2';   cfg.toi             = time_list;
        cfg.foi                     = freq_list;    cfg.t_ftimwin       = 5./cfg.foi;
        cfg.tapsmofrq               = 0.1 *cfg.foi;
        freq                        = ft_freqanalysis(cfg,data_repair);
        
        % exclude trials preceeded with response
        % and average to save space
        cfg                         = [];
        cfg.trials                  = find(freq.trialinfo(:,5) == 0);
        freq                        = ft_selectdata(cfg,freq);
        freq                        = ft_combineplanar([],ft_freqdescriptives([],freq));
        freq                        = rmfield(freq,'cfg');
        
        dirdata                     = 'J:/temp/nback/data/gamma/';
        fname_out                   = [dirdata 'sub' num2str(nsuj) '.sess' num2str(nsess) '.sensor.gamma.avg.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'freq');toc; clear freq;
        
    end
end