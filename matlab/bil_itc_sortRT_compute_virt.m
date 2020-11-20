function phase_lock = bil_itc_sortRT_compute_virt(freq_comb,nb_bin)

all_rt                                          = [[1:length(freq_comb.trialinfo)]'  freq_comb.trialinfo(:,14)];
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
    cfg.time                                    = freq_comb.time([1 end]);
    cfg.freq                                    = freq_comb.freq([1 end]);
    
    phase_lock{nb}                              = mbon_PhaseLockingFactor(freq_comb, cfg);
    phase_lock{nb}.mean_rt                      = mean(all_rt(lm1:lm2,2));
    phase_lock{nb}.med_rt                       = median(all_rt(lm1:lm2,2));
    phase_lock{nb}.index                        = cfg.index;
    
end