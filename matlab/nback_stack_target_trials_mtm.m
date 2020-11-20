clear;close all;

suj_list                   	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                = ['sub' num2str(suj_list(nsuj))];
    load(['J:/temp/nback/data/grad_orig/grad' num2str(suj_list(nsuj)) '.mat']);
    
    for nback = [0 1 2]
        
        fname           	= ['I:\nback\preproc\' suj_name '.' num2str(nback) 'back.rearranged.mat'];
        fprintf('loading %s\n',fname);
        load(fname); clear fname;
        
        cfg                 = [];
        cfg.trials          = find(data.trialinfo(:,3) == 1);
        data                = ft_selectdata(cfg,data); data = rmfield(data,'cfg');
        
        time_lim            = round(data.time{1}(1),1) : 0.01 : round(data.time{1}(end),1);
        freq_lim            = [1:1:30 32:2:50 55:5:100];
        
        data.grad           = grad;
        data_repair       	= megrepair(data); clear data;
        
        cfg                 = [] ;
        cfg.output          = 'pow';
        cfg.method          = 'mtmconvol';
        cfg.keeptrials      = 'yes';
        cfg.pad             = 10;
        cfg.taper           = 'hanning';
        cfg.foi             = freq_lim;
        cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
        cfg.tapsmofrq       = 0.2 *cfg.foi;
        cfg.toi             = time_lim;
        freq                = ft_freqanalysis(cfg,data_repair);
        freq                = rmfield(freq,'cfg');
        
        ext_freq            = h_freqparam2name(cfg);
        freq_comb           = ft_combineplanar([],freq);
        
        fname_out           = ['I:\nback\tf\' suj_name '.' num2str(nback) 'back.' ext_freq '.nonfill.rearranged.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'freq_comb','-v7.3');toc; 
        
        keep suj_list nsuj suj_name nback grad
        
    end
end