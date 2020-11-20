clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for n_suj = 1:length(suj_list)
    for n_ses = 1:2
        
        fname                   = ['../../data/source/virtual/0.5cm/sub' num2str(suj_list(n_suj)) '.session' num2str(n_ses) '.brain0.5.broadband.dwn80.virt.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % add session to end of trial_info
        data.trialinfo          = [data.trialinfo repmat(n_ses,length(data.trialinfo),1)];
        
        data_car{n_ses}         = data; clear data;
        
        
    end
    
    data                        = ft_appenddata([],data_car{:}); clear data_car;
    
    cfg                         = [];
    cfg.demean                  = 'yes';
    cfg.baselinewindow          = [-0.1 0];
    cfg.lpfilter                = 'yes';
    cfg.lpfreq                  = 20;
    data                        = ft_preprocessing(cfg,data);
    
    avg                         = ft_timelockanalysis([], data);

    fname_out                   = ['../../data/erf/sub' num2str(suj_list(n_suj)) '.brainbroadband.erf.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'avg','-v7.3');toc
    
end