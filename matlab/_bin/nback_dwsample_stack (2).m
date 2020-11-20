clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    
    i                               = 0;
    
    for nsess = 1:2
        
        %         fname                       = ['../data/stacked/data_sess' num2str(nsess) '_s' num2str(nsuj) '_3stacked.mat'];
        fname                       = ['../data/prepro/stack_exl/sub' num2str(nsuj) '.sess' num2str(nsess) '.stk.exl.mat'];
        
        fprintf('\nloading %s',fname);
        load(fname);
        
        i                           = i+1;
        alldata{i}                  = data; clear data;
        
    end
    
    data                            = ft_appenddata([],alldata{:}); clear alldata;
    data                            = rmfield(data,'cfg');
    
    cfg                             = [];
    cfg.resamplefs                  = 100;
    cfg.detrend                     = 'no';
    cfg.demean                      = 'yes';
    data                            = ft_resampledata(cfg, data);
    data                            = rmfield(data,'cfg');
    
    index                           = data.trialinfo(:,2) - 4;
    
    dir_out                         = '../data/prepro/stack_exl_dwn/';
    
    fname_out                       = [dir_out 'sub' num2str(nsuj) '.stk.exl.dwnsmple.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'data','-v7.3');toc;
    
    fname_out                       = [dir_out 'sub' num2str(nsuj) '.stk.exl.trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'index');toc;
    
    clc;
    
end