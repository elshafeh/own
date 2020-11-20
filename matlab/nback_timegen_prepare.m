clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    
    fname                                               = ['../data/prepro/stack_dwn/data' num2str(nsuj) '.3stacked.dwsmple.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    index                                               = data.trialinfo(:,[3 14 25]);
    index                                               = rem(index,10)+1;
    
    chk                                                 = [];
    
    for nrow = 1:length(index)
        chk                                             = [chk length(unique(index(nrow,:)))];
    end
    
    ix_trials                                           = find(chk == 3);
    
    cfg                                                 = [];
    cfg.trials                                          = ix_trials;
    cfg.latency                                         = [-0.1 6];    
    data                                                = ft_selectdata(cfg,data);
    
    cfg                                                 = [];
    cfg.resamplefs                                      = 60;
    cfg.detrend                                         = 'no';
    cfg.demean                                          = 'no';
    data                                                = ft_resampledata(cfg, data);
    data                                                = rmfield(data,'cfg');
    
    index                                               = [index(ix_trials,:) data.trialinfo(:,2)-4];
    
    keep nsuj index data
    
    fname_out                                           = ['../data/decode/stack/data' num2str(nsuj) '.stack.noreplicate.60dwsmple.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'data','-v7.3');toc;
    
    fname_out                                           = ['../data/decode/stack/data' num2str(nsuj) '.stack.noreplicate.60dwsmple.trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'index');toc;
    
end