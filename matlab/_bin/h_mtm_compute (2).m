function h_mtm_compute(data,ns,nsess,time_lim,freq_lim,list_index,petit_ext)

% quickly computes fft for each task condition
% 0 , 1 and 2 back;

% list_index                  = [4 5 6 10];

list_name{4}                  = {'0back'};
list_name{5}                  = {'1back'};
list_name{6}                  = {'2back'};
list_name{10}                 = {'allback'};

for nc = 1:length(list_index)
    
    if list_index(nc) == 10
        ix                  = 1:length(data.trialinfo);
    else
        ix                  = find(data.trialinfo(:,2) == list_index(nc));
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
        freq_comb           = ft_combineplanar([],freq);
        
        fname_out           = ['../data/tf/sub' num2str(ns) '.sess' num2str(nsess) '.' list_name{list_index(nc)}{:} '.' ext_freq '.' petit_ext '.mat'];
        
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'freq_comb','-v7.3');toc

    end
end
