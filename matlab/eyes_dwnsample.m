clear;

% clear;

list_suj                      	= {};
for j = 1:9
    list_suj{j,1}              	= ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:22,24:30]
    j                          	= j+1;
    list_suj{j,1}            	= ['sub0', num2str(k)];
end

keep list_suj

for nsuj = 22:length(list_suj)
    
    suj_name                            = list_suj{nsuj};
    
    % load data in
    fname                               = ['P:/3015039.05/data/' suj_name '/preproc/' suj_name '_stimLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % for some trials the the cue-stim timing was off ; got rid of those
    cfg                                 = [];
    cfg.trials                          = find(dataPostICA_clean.trialinfo(:,5) < 3);
    dataPostICA_clean                   = ft_selectdata(cfg,dataPostICA_clean);
    
    % downsample and demean to avoid block-design offset differences
    cfg                                 = [];
    cfg.resamplefs                      = 200;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'no';
    data                                = ft_resampledata(cfg, dataPostICA_clean); clear dataPostICA_clean;
    data                                = rmfield(data,'cfg');
    
    % Save data
    fname                               = ['I:\eyes\preproc\' suj_name '.stimLock.dwn' num2str(cfg.resamplefs) '.mat'];
    fprintf('saving %s\n',fname);
    save(fname,'data','-v7.3');
    
    % change lock
    data                                = h_eyes_changelock(data);
    
    % Save data
    fname                               = ['I:\eyes\preproc\' suj_name '.cueLock.dwn' num2str(cfg.resamplefs) '.mat'];
    fprintf('saving %s\n',fname);
    save(fname,'data','-v7.3');
    
    clear data;
    
end