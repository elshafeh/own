clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nses = 1:2
        
        dir_data            = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nses) '/'];
        fname               = [dir_data 'data_sess' num2str(nses) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                 = [];
        cfg.trials          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                = ft_selectdata(cfg,data);
        
        sess_carr{nses}     = megrepair(data);
        
    end
    
    data                    = ft_appenddata([],sess_carr{:}); clear sess_carr;
    
    %-%-% low pass filtering for ERF computation
    cfg                     = [];
    cfg.demean              = 'yes';
    cfg.baselinewindow      = [-0.1 0];
    cfg.lpfilter            = 'yes';
    cfg.lpfreq              = 20;
    data_preproc          	= ft_preprocessing(cfg,data);
    
    trialinfo               = [];
    trialinfo(:,1)          = data.trialinfo(:,1); % condition
    trialinfo(:,2)          = data.trialinfo(:,3); % stim category
    trialinfo(:,3)          = rem(data.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)          = data.trialinfo(:,6); % response
    trialinfo(:,5)          = data.trialinfo(:,7); % rt
    trialinfo(:,6)          = 1:length(data.trialinfo); % trial indices to match with bin
    
    list_stim               = {'first' 'target' 'allstim'};
    
    for nstim = [3]
        %% compute ERFs
        
        cfg                 = [];
        
        if nstim < 3
            cfg.trials  	= find(trialinfo(:,2) == nstim); % target or first
        else
            cfg.trials      = find(trialinfo(:,2) > -1); % all
        end
        
        avg                 = ft_timelockanalysis(cfg, data_preproc);
        
        avg_comb            = ft_combineplanar([],avg);
        avg_comb            = rmfield(avg_comb,'cfg'); clc;
        
        dir_data            = '~/Dropbox/project_me/data/nback/corr/erf/';
        fname_out           = [dir_data 'sub' num2str(nsuj) '.allback.allbehav.' list_stim{nstim} '.erfComb.mat'];
        
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'avg_comb','-v7.3');toc
        
        %% compute FFT
        
        list_time_window    = [-0.499 0; 0 0.499];
        list_time_name      = {'pre' 'post'};
        
        for ntime = [1 2]
            
            % select time window and trials
            cfg           	= [];
            cfg.latency  	= list_time_window(ntime,:);
            
            if nstim < 3
                cfg.trials	= find(trialinfo(:,2) == nstim); % target or first
            else
                cfg.trials 	= find(trialinfo(:,2) > -1); % all
            end
            
            fft_data       	= ft_selectdata(cfg, data);
            
            % compute fft
            cfg           	= [] ;
            cfg.output    	= 'pow';
            cfg.method    	= 'mtmfft';
            cfg.keeptrials 	= 'no';
            cfg.pad         = 1;
            cfg.foi         = 1:1/cfg.pad:100;
            cfg.taper     	= 'hanning';
            cfg.tapsmofrq  	= 0 ;
            freq        	= ft_freqanalysis(cfg,fft_data);
            
            freq_comb     	= ft_combineplanar([],freq);
            freq_comb      	= rmfield(freq_comb,'cfg');
            
            dir_data       	= '~/Dropbox/project_me/data/nback/corr/fft/';
            fname_out     	= [dir_data 'sub' num2str(nsuj) '.allback.allbehav.' list_stim{nstim} '.' list_time_name{ntime}  '.fft.mat'];
            
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'freq_comb','-v7.3');toc
            
        end
        
        %% compute MTM
        
        cfg                 = [] ;
        cfg.output          = 'pow';
        cfg.method          = 'mtmconvol';
        cfg.keeptrials      = 'no';
        cfg.pad             = 'maxperlen';
        cfg.taper           = 'hanning';
        
        if nstim < 3
            cfg.trials      = find(trialinfo(:,2) == nstim); % target or first
        else
            cfg.trials      = find(trialinfo(:,2) > -1); % all
        end
        
        cfg.foi             = [1:1:30 32:2:100];
        cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
        cfg.tapsmofrq       = 0.2 *cfg.foi;
        cfg.toi             = -1.5:0.02:2;
        
        freq                = ft_freqanalysis(cfg,data);                
        freq_comb           = ft_combineplanar([],freq);
        freq_comb           = rmfield(freq_comb,'cfg');
        
        dir_data            = '~/Dropbox/project_me/data/nback/corr/mtm/';
        fname_out           = [dir_data 'sub' num2str(nsuj) '.allback.allbehav.' list_stim{nstim} '.mtm.mat'];
        
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'freq_comb','-v7.3');toc
        
    end
end