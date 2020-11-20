clear ;

list_files = dir('../data/sub*/preprocessed/*secondreject*');

for nf = 1:length(list_files)
    
    nme_prts                            = strsplit(list_files(nf).name,'_');
    suj                                 = nme_prts{1};
    modality                            = nme_prts{end}(1:3);
    
    chk_files                           = 0;
    
    fname                               = [list_files(nf).folder '/' list_files(nf).name];
    fprintf('Loading %s \n',fname);
    load(fname);
    
    cfg                                 = [];
    cfg.latency                         = [-0.5 0]; % this needs to be put in the filename
    prestim_data                        = ft_selectdata(cfg, secondreject_postica); % select corresponding data
    
    cfg                                 = [] ;
    cfg.output                          = 'pow';
    cfg.method                          = 'mtmfft';
    
    %     cfg.trials                          = find(prestim_data.trialinfo(:,3) == 1); %
    % we put all trials but keep in mind tha tbinning will be done only on
    % noisy
    
    cfg.keeptrials                      = 'yes';
    cfg.pad                             = 3 ;
    cfg.foi                             = 1:1/cfg.pad:25;
    cfg.taper                           = 'hanning';
    cfg.tapsmofrq                       = 0 ;
    freq                                = ft_freqanalysis(cfg,prestim_data);
    
    freq                                = rmfield(freq,'cfg');
    
    fname                               = ['../data/' suj '/tf/' suj '_fftsamaha_' modality '.mat']; % this could be nicer
    fprintf('Saving %s\n',fname);
    save(fname,'freq','-v7.3');
    
end