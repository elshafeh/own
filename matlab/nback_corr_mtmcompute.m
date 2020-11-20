clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    for nsess = 1:2
        
        fname                               = ['K:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        data_repair                         = megrepair(data); clear data;
        
        index                               = [data_repair.trialinfo(:,1)-4 data_repair.trialinfo(:,5)+1];
        
        for nback = [0 1 2]
            for ncorr = [0 1 2]
                
                if ncorr <2
                    ix                      = find(index(:,1) == nback & index(:,2) == ncorr);
                else
                    ix                      = find(index(:,1) == nback );
                end
                
                if ~isempty(ix)
                    
                    cfg                     = [] ;
                    cfg.output              = 'pow';
                    cfg.method              = 'mtmconvol';
                    cfg.keeptrials          = 'no';
                    cfg.pad                 = 'maxperlen';
                    cfg.taper               = 'hanning';
                    cfg.trials              = ix;
                    
                    cfg.foi                 = 5:1:30;
                    cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
                    cfg.tapsmofrq           = 0.1 *cfg.foi;
                    
                    cfg.toi                 = -1.5:0.03:2;
                    
                    freq                    = ft_freqanalysis(cfg,data_repair);
                    freq                    = rmfield(freq,'cfg');
                    
                    ext_freq                = h_freqparam2name(cfg);
                    freq_comb               = ft_combineplanar([],freq);
                    freq_comb             	= rmfield(freq_comb,'cfg');
                    
                    list_corr               = {'incorrTrials','corrTrials','allTrials'};
                    
                    ext_freq                = strsplit(ext_freq,'.');
                    ext_freq                = ext_freq{1};
                    
                    fname_out               = ['K:/nback/tf/sub' num2str(nsuj) '.sess' num2str(nsess) '.' num2str(nback) 'back.' list_corr{ncorr+1} '.' ext_freq '.mat'];
                    fprintf('Saving %s\n',fname_out);
                    tic;save(fname_out,'freq_comb','-v7.3');toc
                    
                end
            end
        end
    end
end