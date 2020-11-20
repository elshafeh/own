function h_mtm_compute(data,ns,nsess,time_lim,freq_lim,petit_ext)

% quickly computes fft for each task condition
% 0 , 1 and 2 back;

list_name                       = {'0back','1back','2back'};
list_stim                       = {'first','target'};

for ncond = 1:length(list_name)
    for nstim = 1:length(list_stim)
        
        if ncond == 1
            ix                  = find(data.trialinfo(:,1) == ncond+3 & data.trialinfo(:,3) == nstim-1);
        else
            ix                  = find(data.trialinfo(:,1) == ncond+3 & data.trialinfo(:,3) == nstim);
        end
        
        if ~isempty(ix)
            
            cfg                 = [] ;
            cfg.output          = 'pow';
            cfg.method          = 'mtmconvol';
            cfg.keeptrials      = 'no';
            cfg.pad             = 'maxperlen';
            cfg.taper           = 'hanning';
            cfg.trials          = ix;
            
            cfg.foi             = freq_lim;
            cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
            cfg.tapsmofrq       = 0.2 *cfg.foi;
            
            cfg.toi             = time_lim;
            
            freq                = ft_freqanalysis(cfg,data);
            freq                = rmfield(freq,'cfg');
            
            ext_freq            = h_freqparam2name(cfg);
            ext_freq            = strsplit(ext_freq,'.');
            ext_freq            = ext_freq{5};
            
            freq_comb           = ft_combineplanar([],freq);
            
            fname_out           = ['J:/temp/nback/data/tf_sens/sub' num2str(ns) '.sess' num2str(nsess) '.' ... 
                list_name{ncond} '.' list_stim{nstim} '.stim.' ext_freq '.' petit_ext '.mat'];
            
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'freq_comb','-v7.3');toc
            
        end
    end
end
