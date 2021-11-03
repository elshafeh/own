clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                             	= [1:33 35:36 38:44 46:51]; %

for nsuj = 1:length(suj_list)
    
    
    fname                               = ['~/Dropbox/project_me/data/nback/prepro/nback_1/data_sess1_s' num2str(suj_list(nsuj)) '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    %-%-% exclude trials with a previous response
    % and 0back trials
    cfg                                 = [];
    cfg.trials                          = find(data.trialinfo(:,1) == 4);
    data_concat                        	= ft_selectdata(cfg,data);
    
    trialinfo(:,1)                    	= data_concat.trialinfo(:,1); % condition
    trialinfo(:,2)                     	= data_concat.trialinfo(:,3); % stim category
    trialinfo(:,3)                    	= rem(data_concat.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                    	= 1:length(data_concat.trialinfo); % trial indices to match with bin
    
    for cfg_demean = {'no'}
        
        %-%-% downsample for decoding
        cfg                         	= [];
        cfg.resamplefs                  = 100;
        cfg.detrend                  	= 'no';
        cfg.demean                    	= cfg_demean{:};
        data                         	= ft_resampledata(cfg, data_concat);
        data                          	= rmfield(data,'cfg');
        index                        	= trialinfo;
        
        dir_out                      	= '~/Dropbox/project_me/data/nback/bin_decode/preproc/';
        ext_name_out                 	= ['0back.broadband.' cfg_demean{:} 'demean'];
        fname_out                   	= [dir_out 'sub' num2str(suj_list(nsuj)) '.' ext_name_out '.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'data','-v7.3');toc;
        
        fname_out                     	= [dir_out 'sub' num2str(suj_list(nsuj)) '.' ext_name_out '.trialinfo.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'index');toc;
        
    end
    
    keep suj_list nsuj
    
end