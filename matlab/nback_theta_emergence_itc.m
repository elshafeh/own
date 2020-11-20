clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    
    load(['J:/temp/nback/data/grad_orig/grad' num2str(nsuj) '.mat']);
    
    for nsess = [1 2]
        fname                       = ['J:/temp/nback/data/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        cfg                         = [];
        cfg.trials                  = find(data.trialinfo(:,5) == 0);
        tmp{nsess}                  = ft_selectdata(cfg,data);clear data;
    end
    
    data                            = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                       = grad;
    data_repair                     = megrepair(data); clear data;
    
    % - - % attention !!
    data_repair                     = h_removeEvoked(data_repair);
    % - - % attention !!
    
    t1                              = -0.5; t2  = 2;
    f1                              = 1;    f2 	= 10;
    
    cfg                          	= [];
    cfg.output                   	= 'fourier';
    cfg.method                  	= 'mtmconvol';
    cfg.taper                    	= 'hanning';
    cfg.foi                     	= f1:1:f2;
    cfg.toi                         = t1:0.05:t2;
    cfg.t_ftimwin                	= ones(length(cfg.foi),1).*0.5;   % 5 cycles
    cfg.keeptrials              	= 'yes';
    cfg.pad                     	= 10;
    freq                            = ft_freqanalysis(cfg,ft_combineplanar([],data_repair));
    freq                            = rmfield(freq,'cfg');
    
    cfg                           	= [];
    cfg.indexchan                 	= 'all';
    cfg.index                    	= 'all';
    cfg.alpha                    	= 0.05;
    cfg.time                        = [t1 t2];
    cfg.freq                     	= [f1 f2];
    phase_lock                    	= mbon_PhaseLockingFactor(freq, cfg); clear t1 t2 f1 f2;
    
    dirdata                         = 'J:/temp/nback/data/theta/';
    fname_out                       = [dirdata 'sub' num2str(nsuj) '.combinedplanar.minevoked.itc.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'phase_lock');toc; clear freq;
    
end