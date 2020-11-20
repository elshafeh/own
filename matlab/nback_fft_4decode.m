clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = [1 2]
        fname              	= ['J:/temp/nback/data/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                	= [];
        cfg.demean         	= 'yes';
        data_carr{nsess}  	= ft_preprocessing(cfg, data); clear data;
        
    end
    
    orig_data             	= ft_appenddata([],data_carr{:});
    
    cfg                     = [];
    cfg.toilim              = [0.4 1.4];
    orig_data               = ft_redefinetrial(cfg,orig_data);
    
    % load grad
    fname = ['D:\Dropbox\project_nback\data\grad_orig\grad' num2str(nsuj) '.mat'];
    load(fname);
    %     orig_data.grad        	= grad; %clear grad;
    orig_data               = rmfield(orig_data,'cfg');

    cfg                     = [] ;
    cfg.output              = 'pow';
    cfg.method              = 'mtmfft';
    cfg.keeptrials          = 'yes';
    cfg.taper               = 'hanning';
    cfg.pad                 = 1.2;
    cfg.foi                 = 1:1:100;
    cfg.tapsmofrq           = 0;
    cfg.keeptrials       	= 'yes';
    freq                 	= ft_freqanalysis(cfg,orig_data);
    
    % - % the idea here is to save each frequency as fieldtrip epoched data
    % structure
    
    data                   	= orig_data;
    data.fsample        	= 1;
    data.trial            	= squeeze(num2cell(freq.powspctrm,[2 3]));
    
    for xi = 1:length(data.trial)
        data.trial{xi}     	= squeeze(data.trial{xi});
        data.time{xi}    	= round(freq.freq);
    end
    
    index                   = data.trialinfo;
    dirdata                	= 'J:/temp/nback/data/fft/';
    
    fname_out               = [dirdata 'sub' num2str(nsuj) '.400t1400ms.fft.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'data');toc; 
    
    fname_out               = [dirdata 'sub' num2str(nsuj) '.400t1400ms.fft.trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'index');toc; clear inde data freq;
    
    keep nsuj
    
end