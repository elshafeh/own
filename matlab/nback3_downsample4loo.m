clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    for nsess = 1:2
        
        
        fname                               = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                                = ft_selectdata(cfg,data);
        
        sess_norepair{nsess}                = data; clear data; % we need this cause the non-repaired data doesn't work with MNE-python
        
    end
    
    cfg_demean                              = 'no';
    
    %-%-%- append and downsample
    cfg                                     = [];
    cfg.resamplefs                          = 70;
    cfg.detrend                             = 'no';
    cfg.demean                              = cfg_demean;
    data_downsample                         = ft_resampledata(cfg,  ft_appenddata([],sess_norepair{:})); clear sess_norepair
    
    %-%-% rearragnge trialinfo
    trialinfo(:,1)                       	= data_downsample.trialinfo(:,1); % condition
    trialinfo(:,2)                       	= data_downsample.trialinfo(:,3); % stim category
    trialinfo(:,3)                        	= rem(data_downsample.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                       	= data_downsample.trialinfo(:,6); % response
    trialinfo(:,5)                       	= data_downsample.trialinfo(:,7); % rt
    trialinfo(:,6)                        	= 1:length(data_downsample.trialinfo); % trial indices to match with bin
    data_downsample.trialinfo              	= trialinfo; clear trialinfo

    %-%-% Save data + trialinfo for decoding
    cfg                                     = [];
    cfg.latency                             = [-0.3 2.05];
    data                                    = ft_selectdata(cfg,data_downsample); clear data_downsample;
    data                                    = rmfield(data,'cfg');
    index                                   = data.trialinfo;
    
    dir_out                                 = '~/Dropbox/project_me/data/nback/bin_decode/preproc/';
    ext_name_out                            = [dir_out 'sub' num2str(suj_list(nsuj)) '.data4loodecoding.' cfg_demean 'demean'];
    fname_out                               = [ext_name_out '.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'data','-v7.3');toc;
    
    fname_out                               = [ext_name_out '.trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'index');toc;
    
end