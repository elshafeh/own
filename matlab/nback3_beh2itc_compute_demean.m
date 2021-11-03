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
        
        clear data
        
    end
    
    data                                    = ft_appenddata([],sess_carr{:}); clear sess_carr;
    
    % -- % -- TO REMOVE OFFSET % -- % -- 
    cfg                                     = [];
    cfg.demean                              = 'yes';
    cfg.baselinewindow                      = [-0.1 0];
    data                                    = ft_preprocessing(cfg,data);
    % -- % -- TO REMOVE OFFSET % -- % -- 
    
    trialinfo                               = [];
    trialinfo(:,1)                          = data.trialinfo(:,1); % condition
    trialinfo(:,2)                          = data.trialinfo(:,3); % stim category
    trialinfo(:,3)                          = rem(data.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                          = data.trialinfo(:,6); % response
    trialinfo(:,5)                          = data.trialinfo(:,7); % rt
    trialinfo(:,6)                          = 1:length(data.trialinfo); % trial indices to match with bin
    
    list_stim                               = {'target' 'allstim'};
    list_behav                              = {'fast' 'slow'};

    index{1}                                = nbk_trialinfo2rtindex(trialinfo,'target');
    index{2}                                = nbk_trialinfo2rtindex(trialinfo,'all');
    
    for nstim = [1 2]
        for nback = [1 2]
            for nbehav = [1 2]

                cfg                         = [];
                cfg.trials                  = index{nstim}{nback,nbehav};
                data_select                 = ft_selectdata(cfg,data);
                
                time_win1                 	= -1.5;
                time_win2                 	= 2.5;
                
                freq1                       = 1;
                freq2                       = 40;
                
                cfg                      	= [];
                cfg.output              	= 'fourier';
                cfg.method                 	= 'mtmconvol';
                cfg.taper                	= 'hanning';
                cfg.foi                  	= freq1:1:freq2;
                cfg.toi                  	= time_win1:0.05:time_win2;
                cfg.t_ftimwin             	= ones(length(cfg.foi),1).*0.5;   % 5 cycles
                cfg.keeptrials          	= 'yes';
                cfg.pad                   	= 5;
                
                freq                        = ft_freqanalysis(cfg,data_select);
                
                cfg                        	= []; cfg.method = 'svd';
                freq_comb               	= ft_combineplanar(cfg,freq);
                
                cfg                      	= [];
                cfg.indexchan            	= 'all';
                cfg.index                	= 'all';
                cfg.alpha                	= 0.05;
                cfg.time                 	= [time_win1 time_win2];
                cfg.freq                	= [freq1 freq2];
                phase_lock                  = mbon_PhaseLockingFactor(cfg,freq_comb);
  
                dir_data                    = '~/Dropbox/project_me/data/nback/tf/itc/';
                fname_out                   = [dir_data 'sub' num2str(nsuj) '.' num2str(nback) 'back.' list_stim{nstim}];
                fname_out                   = [fname_out '.' list_behav{nbehav} '.itc.withevoked.demean.mat'];
                fprintf('Saving %s\n',fname_out);
                
                tic;save(fname_out,'phase_lock','-v7.3');toc
                
            end
        end
    end
    
end