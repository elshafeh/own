clear ; close all;

suj_list                                = dir('../data/sub*/preproc/*_firstCueLock_ICAlean_finalrej.mat');

for ns = 1:length(suj_list)
    
    subjectName                         = suj_list(ns).name(1:6);
    chk                                 = dir([suj_list(ns).folder '/' subjectName '.firstcuelock.dwnsample100Hz.mat']);
    
    if isempty(chk)
        
        fname                               = [suj_list(ns).folder '/' suj_list(ns).name];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        nw_trialinfo                        = dataPostICA_clean.trialinfo(:,[1 7 8 16]); % orig_code task cue correct
        nw_trialinfo(nw_trialinfo(:,1) == 13,1)     = 20 + nw_trialinfo(nw_trialinfo(:,1) == 13,2);
        
        nw_trialinfo                        = nw_trialinfo(:,[1 4]); % new-code correct
        
        data                                = dataPostICA_clean;
        data.trialinfo                      = nw_trialinfo;
        
        cfg                                 = [];
        cfg.resamplefs                      = 100;
        cfg.detrend                         = 'no';
        cfg.demean                          = 'yes';
        data                                = ft_resampledata(cfg, data);
        data                                = rmfield(data,'cfg');
        
        ext_lock                            = '.firstcuelock.';
        
        fname                               = [suj_list(ns).folder '/' subjectName ext_lock 'dwnsample100Hz.mat'];
        fprintf('Saving %s\n',fname);
        tic;save(fname,'data','-v7.3');toc;
        
        index                               = data.trialinfo;
        fname                               = [fname(1:end-4) '_trialinfo.mat'];
        fprintf('Saving %s\n',fname);
        tic;save(fname,'index');toc;
        
    end
end