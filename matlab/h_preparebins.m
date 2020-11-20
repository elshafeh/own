function [bin_summary] = h_preparebins(freq,apeak,nb_bin,bnwidth)

cfg                         = [];
cfg.foi                     = [apeak-bnwidth apeak+bnwidth]; % alpha peak for the subject and modlaity
cfg.channel                 = 'all';
cfg.bin                     = nb_bin;
bins                        = prepare_bin(cfg,freq);

for nb = 1:size(bins,2)
    
    flg                     = freq.trialinfo(bins(:,nb),[16 14]);
    flg                     = flg(~isnan(flg(:,1)) & ~isnan(flg(:,2)),:);
    
    lngth                   = size(flg,1);
    
    perc_corr(nb)           = sum(flg(:,1))/lngth; % corr
    med_rt(nb)              = median(flg(:,2)); % rt
    
end

bin_summary.bins            = bins;
bin_summary.perc_corr       = perc_corr;
bin_summary.med_rt          = med_rt;
