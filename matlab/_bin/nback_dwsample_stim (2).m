clear ;

suj_list                                        = [1:33 35:36 38:44 46:51];

for ns = 46:51
    
    % combine data from both sessions to get more trial numbers
    
    for nback = 1:2
        
        fname                                   = ['../data/prepro/nback_' num2str(nback) '/data_sess' num2str(nback) '_s' num2str(ns) '.mat'; ];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        data                                    = rmfield(data,'grad');
        data                                    = rmfield(data,'cfg');
        
        cfg                                     = [];
        cfg.latency                             = [-0.1 1];
        data                                    = ft_selectdata(cfg,data);
        
        cfg                                     = [];
        cfg.resamplefs                          = 100;
        cfg.detrend                             = 'no';
        cfg.demean                              = 'yes';
        data                                    = ft_resampledata(cfg, data);
        data                                    = rmfield(data,'cfg');
        
        % Stimuli are coded 1-10 + 10,20,30 or 40
        data.trialinfo                          = [rem(data.trialinfo(:,2),10)+1 repmat(nback,length(data.trialinfo),1)];
        
        tmp{nback}                              = data; clear data;
        
    end
    
    data                                        = ft_appenddata([],tmp{:}); 
    index                                       = data.trialinfo;
    
    fname_out                                   = ['../data/decode/nback/data' num2str(ns) '.nback.dwsmple.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'data','-v7.3');toc;
    
    fname_out                                   = ['../data/decode/nback/data' num2str(ns) '.nback.dwsmple.trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'index');toc;
    
    keep nback ns
    
end