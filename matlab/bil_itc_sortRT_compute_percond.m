function phase_lock = bil_itc_sortRT_compute_percond(subjectName,freq_comb,nb_bin,ext_name)

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end


list_cue                                            = {'pre','retro'};

for ncue = 1:2
    
    % bin according to each cue (pre and retro)
    cfg                                             = [];
    cfg.trials                                      = find(freq_comb.trialinfo(:,8) == ncue);
    sub_freq                                        = ft_selectdata(cfg,freq_comb);
    
    all_rt                                          = [[1:length(sub_freq.trialinfo)]'  sub_freq.trialinfo(:,14)];
    all_rt                                          = sortrows(all_rt,2);
    
    [indx]                                          = calc_tukey(all_rt(:,2));
    all_rt                                          = all_rt(indx,:);
    
    bin_size                                        = floor(length(all_rt)/nb_bin);
    
    for nb = 1:nb_bin
        
        lm1                                         = 1+bin_size*(nb-1);
        lm2                                         = bin_size*nb;
        
        cfg                                         = [];
        cfg.indexchan                               = 'all';
        
        cfg.index                                   = all_rt(lm1:lm2,1);
        cfg.alpha                                   = 0.05;
        cfg.time                                    = [-0.1 6.5];
        cfg.freq                                    = [1 10];
        
        phase_lock{nb}                              = mbon_PhaseLockingFactor(sub_freq, cfg);
        phase_lock{nb}.mean_rt                      = mean(all_rt(lm1:lm2,2));
        phase_lock{nb}.med_rt                       = median(all_rt(lm1:lm2,2));
        
        phase_lock{nb}.index                        = cfg.index;
        
    end
    
    fname                                           = [project_dir 'data/' subjectName '/tf/' subjectName '.' list_cue{ncue} 'cuelock.itc.comb.' num2str(nb_bin) 'binned.allchan.' ext_name '.mat'];
    fprintf('\nSaving %s\n',fname);
    tic;save(fname,'phase_lock','-v7.3');toc;
    
end