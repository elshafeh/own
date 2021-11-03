function [bin_summary] = nback_func_preparebin_sessionconcat(freq,apeak,nb_bin,bnwidth)

cfg                         = [];
cfg.foi                     = [apeak-bnwidth apeak+bnwidth]; % alpha peak for the subject and modlaity
cfg.channel                 = 'all';
cfg.bin                     = nb_bin;
bins                        = prepare_bin(cfg,freq);

for nb = 1:nb_bin
    
    vct_target              = freq.trialinfo(bins(:,nb),[2 4 5]);
    vct_target              = vct_target(vct_target(:,1) == 2,[2 3]); % find target
    
    vct_resp                = vct_target(:,1);
    vct_resp(vct_resp == 1 | vct_resp == 3) = 1;
    vct_resp(vct_resp == 2 | vct_resp == 4) = 0;
    
    vct_rt                	= vct_target(:,2);
    vct_rt(vct_rt == 0)     = NaN;
    
    vct_rt_correct          = vct_rt(vct_resp == 1);
    
    perc_corr(nb)           = sum(vct_resp)/length(vct_resp); % corr
    med_rt(nb)              = nanmedian(vct_rt); % rt
    med_rt_correct(nb)   	= nanmedian(vct_rt_correct); % rt
    
end

bin_summary.bins            = bins;
bin_summary.perc_corr       = perc_corr;
bin_summary.med_rt          = med_rt;
bin_summary.med_rt_correct 	= med_rt_correct;
