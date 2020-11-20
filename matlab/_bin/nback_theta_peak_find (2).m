clear ;

for ns = [1:33 35:36 38:44 46:51]
    
    subjectName                                 = ['sub' num2str(ns)];clc;
    
    for nsess = 1:2
        
        fname                                   = ['/Volumes/heshamshung/nback/stack/data_sess' num2str(nsess) '_s' num2str(ns) '_3stacked.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        data_repair                             = ft_combineplanar([],megrepair(data)); clear data;
        
        %load max-chan
        load(['/Volumes/heshamshung/nback/peak/s' num2str(ns) '.max10chan.p50p200ms.postonset.mat'])
        
        cfg                                     = [];
        cfg.output                              = 'fourier';
        cfg.method                              = 'mtmconvol';
        cfg.taper                               = 'hanning';
        cfg.foi                                 = 1:1:7;
        cfg.toi                                 = -1.5:0.05:6;
        cfg.t_ftimwin                           = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
        cfg.keeptrials                          = 'yes';
        cfg.pad                                 = 'maxperlen';
        freq                                    = ft_freqanalysis(cfg,data_repair);
        
        cfg                                     = [];
        cfg.indexchan                           = 'all';
        cfg.index                               = 'all';
        cfg.alpha                               = 0.05;
        cfg.time                                = [-0.5 5];
        cfg.freq                                = [1 7];
        phase_lock                              = mbon_PhaseLockingFactor(freq, cfg);
        
        fname                                   = ['/Volumes/heshamshung/nback/phase_lock/' subjectName '.ses' num2str(nsess) '.itc.mat'];
        fprintf('\nsaving %s\n',fname);
        save(fname,'phase_lock','-v7.3');
        
        phase_lock                              = rmfield(phase_lock,'rayleigh');
        phase_lock                              = rmfield(phase_lock,'p');
        phase_lock                              = rmfield(phase_lock,'sig');
        phase_lock                              = rmfield(phase_lock,'mask');
        
        p_carr{nsess}                           = phase_lock ; clear phase_lock;
        
    end
    
    phase_lock                                  = ft_freqgrandaverage([],p_carr{:});
    vctr                                        = mean(squeeze(mean(phase_lock.powspctrm,1)),2);
    
    dt_peak                                     = phase_lock.freq(find(max(vctr)));
    
    % save output
    fname_out                                   = ['/Volumes/heshamshung/nback/peak/' subjectName '.delthetapeak.itcbased.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'dt_peak');
    
    keep ns p_carr subjectName
    
end