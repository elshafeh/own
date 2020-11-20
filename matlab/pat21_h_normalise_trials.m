function allsuj_GA = h_normalise_trials(allsuj_GA)

ntrl = [];

for sb = 1:size(allsuj_GA,1)
    for cnd = 1:size(allsuj_GA,2)
        
        ntrl = [ntrl;length(allsuj_GA{sb,cnd}.trialinfo)];
        
    end
end

min_trl = min(ntrl);

for sb = 1:size(allsuj_GA,1)
    for cnd = 1:size(allsuj_GA,2)
        
        cfg                 = [];
        cfg.trials          = PrepAtt2_fun_create_rand_array(1:length(allsuj_GA{sb,cnd}.trialinfo),min_trl);
        allsuj_GA{sb,cnd}   = ft_selectdata(cfg,allsuj_GA{sb,cnd}); 
        
    end
end