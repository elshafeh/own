clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data          	= '~/Dropbox/project_me/data/nback/prepro/nback_1/';
    fname            	= [dir_data 'data_sess1_s' num2str(nsuj) '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    %-%-% exclude trials with a previous response
    cfg              	= [];
    cfg.trials        	= find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) == 4);
    data            	= ft_selectdata(cfg,data);
    
    %-%-% fix channel config
    data              	= megrepair(data);
    
    %-%-% extract trial information
    trialinfo          	= [];
    trialinfo(:,1)   	= data.trialinfo(:,1); % condition
    trialinfo(:,2)    	= data.trialinfo(:,3); % stim category
    trialinfo(:,3)     	= rem(data.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)     	= data.trialinfo(:,6); % response
    trialinfo(:,5)     	= data.trialinfo(:,7); % rt
    trialinfo(:,6)   	= 1:length(data.trialinfo); % trial indices to match with bin
    
    data.trialinfo      = trialinfo; clear trialinfo.
    
    cfg                 = [] ;
    cfg.output          = 'pow';
    cfg.method          = 'mtmconvol';
    cfg.keeptrials      = 'yes';
    cfg.pad             = 4;
    cfg.taper           = 'hanning';
    
    cfg.foi             = [1:1:30 32:2:100];
    
    cfg.t_ftimwin       = 4./cfg.foi;
    cfg.tapsmofrq       = 0.2 *cfg.foi;
    cfg.toi             = -1.5:0.02:1.5;
    
    freq                = ft_freqanalysis(cfg,data);
    freq                = rmfield(freq,'cfg');
    
    freq_comb           = ft_combineplanar([],freq);
    freq_comb           = rmfield(freq_comb,'cfg');
    
    dir_data        	= '~/Dropbox/project_me/data/nback/0back/mtm/';
    fname_out           = [dir_data 'sub' num2str(nsuj) '.0back.singletrial.mtm.mat'];
    
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'freq_comb','-v7.3');toc
    
    clear freq_comb freq
    
    %-%-% low pass filtering
    cfg              	= [];
    cfg.demean        	= 'yes';
    cfg.baselinewindow	= [-0.1 0];
    cfg.lpfilter     	= 'yes';
    cfg.lpfreq        	= 20;
    data              	= ft_preprocessing(cfg,data);
    
    cfg                 = [];
    avg                 = ft_timelockanalysis(cfg, data);
    avg_comb            = ft_combineplanar([],avg);
    avg_comb            = rmfield(avg_comb,'cfg'); clc;
    
    dir_data        	= '~/Dropbox/project_me/data/nback/0back/erf/';
    fname_out           = [dir_data 'sub' num2str(nsuj) '.0back.erf.mat'];
    
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'avg_comb','-v7.3');toc
    
    clear avg_comb data
    
end