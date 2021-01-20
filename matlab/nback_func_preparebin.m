function [bin_summary] = nback_func_preparebin(freq,apeak,nb_bin,bnwidth)

cfg                         = [];
cfg.foi                     = [apeak-bnwidth apeak+bnwidth]; % alpha peak for the subject and modlaity
cfg.channel                 = 'all';
cfg.bin                     = nb_bin;
bins                        = prepare_bin(cfg,freq);

for nb = 1:nb_bin
    
    vct_resp                = freq.trialinfo(bins(:,nb),[6]);
    vct_resp(vct_resp == 1 | vct_resp == 3) = 1;
    vct_resp(vct_resp == 2 | vct_resp == 4) = 0;
    
    vct_rt                	= freq.trialinfo(bins(:,nb),[7]);
    vct_rt(vct_rt == 0)     = NaN;
        
    perc_corr(nb)           = sum(vct_resp)/length(vct_resp); % corr
    med_rt(nb)              = nanmedian(vct_rt); % rt
    
end

bin_summary.bins            = bins;
bin_summary.perc_corr       = perc_corr;
bin_summary.med_rt          = med_rt;