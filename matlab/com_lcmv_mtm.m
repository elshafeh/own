clear;

suj_list                    = [1:4 8:17] ;
data_list                   = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        ext_name            = [suj '.CnD.brainnetome.' data_list{ndata}];
        
        fname_in            = ['../data/lcmv_brain/' ext_name '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        cfg                 = [] ;
        cfg.output          = 'pow';
        cfg.method          = 'mtmconvol';
        cfg.keeptrials      = 'no';
        cfg.foi             = 1:1:40;
        cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
        cfg.toi             = -2:0.03:2.5;
        cfg.taper           = 'hanning';
        cfg.pad             = 'nextpow2';
        cfg.tapsmofrq       = 0.2 *cfg.foi;
        freq                = ft_freqanalysis(cfg,data);
        freq                = rmfield(freq,'cfg');
        
        ext_freq            = h_freqparam2name(cfg);

        fname               = ['../data/tf/' ext_name '.' ext_freq '.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'freq','-v7.3');
        
        fprintf('\ndone\n\n');
        
    end
end