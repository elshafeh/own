clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        dir_data                            = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/'];
        fname                               = [dir_data 'data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0); %
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
    
    list_name                               = {'0back' '1back','2back'};
    list_stim                               = {'first' 'target' 'allstim'};
    list_behav                              = {'correct' 'incorrect' 'fast' 'slow'};
    
    for nback = 1:length(list_name)
        
        for nstim = 2 
            
            nback_addon                     = 3;
            
            if nstim == 3
                flg_nback_stim              = find(trialinfo(:,1) == nback+nback_addon);
            else
                flg_nback_stim              = find(trialinfo(:,1) == nback+nback_addon & trialinfo(:,2) == nstim);
            end
            
            if ~isempty(flg_nback_stim)
                
                sub_info                    = trialinfo(flg_nback_stim,[4 5 6]);
                
                index_trials{1}             = sub_info(find(sub_info(:,1) == 1 | sub_info(:,1) == 3),3); % correct
                index_trials{2}             = sub_info(find(sub_info(:,1) == 2 | sub_info(:,1) == 4),3); % incorrect
                
                sub_info_correct            = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
                sub_info_correct            = sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
                
                median_rt                   = median(sub_info_correct(:,2));
                
                index_trials{3}             = sub_info_correct(find(sub_info_correct(:,2) < median_rt),3); % fast
                index_trials{4}             = sub_info_correct(find(sub_info_correct(:,2) > median_rt),3); % slow
                
                for nbehav = 1
                    
                    if ~isempty(index_trials{nbehav})
                        
                        list_time_window    = [-0.499 0];
                        list_time_name      = {'pre'};
                        
                        for ntime = 1:length(list_time_name)
                            
                            % select time window and trials
                            cfg           	= [];
                            cfg.latency  	= list_time_window(ntime,:);
                            cfg.trials      = index_trials{nbehav};
                            fft_data       	= ft_selectdata(cfg, data);
                            
                            % compute fft
                            cfg           	= [] ;
                            cfg.output    	= 'pow';
                            cfg.method    	= 'mtmfft';
                            cfg.keeptrials 	= 'no';
                            cfg.pad         = 1;
                            cfg.foi         = 1:1/cfg.pad:40;
                            cfg.taper     	= 'hanning';
                            cfg.tapsmofrq  	= 0 ;
                            freq        	= ft_freqanalysis(cfg,fft_data);
                            
                            freq_comb     	= ft_combineplanar([],freq);
                            freq_comb      	= rmfield(freq_comb,'cfg');
                            
                            dir_data     	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
                            fname_out     	= [dir_data 'sub' num2str(nsuj) '.' list_name{nback} '.' list_stim{nstim}];
                            fname_out      	= [fname_out '.' list_behav{nbehav} '.' list_time_name{ntime}  '.fft.mat'];
                            
                            fprintf('Saving %s\n',fname_out);
                            tic;save(fname_out,'freq_comb','-v7.3');toc
                            
                        end
                    end
                end
            end
        end
    end
end