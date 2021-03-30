clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        dir_data                            = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/'];
        fname                               = [dir_data 'data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                                = ft_selectdata(cfg,data);
        
        sess_carr{nsess}                    = megrepair(data);
        
    end
    
    data                                    = ft_appenddata([],sess_carr{:}); clear sess_carr;
    
    trialinfo                               = [];
    trialinfo(:,1)                          = data.trialinfo(:,1); % condition
    trialinfo(:,2)                          = data.trialinfo(:,3); % stim category
    trialinfo(:,3)                          = rem(data.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                          = data.trialinfo(:,6); % response
    trialinfo(:,5)                          = data.trialinfo(:,7); % rt
    trialinfo(:,6)                          = 1:length(data.trialinfo); % trial indices to match with bin
    
    dir_data                                = '~/Dropbox/project_me/data/nback/trialinfo/';
    fname_out                               = [dir_data 'sub' num2str(nsuj) '.trialinfo.mat'];
    
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'trialinfo');toc
    
    clear data trialinfo;
    
end