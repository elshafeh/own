clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        dir_data                   	= ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/'];
        fname                     	= [dir_data 'data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                      	= [];
        cfg.trials              	= find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                      	= ft_selectdata(cfg,data);
        
        sess_carr{nsess}         	= megrepair(data);
        
        clear data
        
    end
    
    data                          	= ft_appenddata([],sess_carr{:}); clear sess_carr;
    
    trialinfo                     	= [];
    trialinfo(:,1)               	= data.trialinfo(:,1);              % condition
    trialinfo(:,2)                	= data.trialinfo(:,3);              % stim category
    trialinfo(:,3)                	= rem(data.trialinfo(:,2),10)+1;    % stim identity
    trialinfo(:,4)                 	= data.trialinfo(:,6);              % response
    trialinfo(:,5)                 	= data.trialinfo(:,7);              % rt
    trialinfo(:,6)                 	= 1:length(data.trialinfo);         % trial indices to match with bin
    
    index                         	= nbk_infocut_load(trialinfo,'all','keep');
    list_back                       = {'1back' '2back' '2back.sub'};
    
    for nback = [1 2 3]
        
        cfg                         = [];
        cfg.trials                  = index{nback};
        data_select                 = ft_selectdata(cfg,data);
        
        time_win1                 	= -1.5;
        time_win2                 	= 2.5;
        
        freq1                       = 6;
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
        fname_out                   = [dir_data 'sub' num2str(nsuj) '.' list_back{nback} '.allstim'];
        fname_out                   = [fname_out '.allbehav.itc.withevoked.mat'];
        fprintf('Saving %s\n',fname_out);
        
        tic;save(fname_out,'phase_lock','-v7.3');toc
        
    end
    
end