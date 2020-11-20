function frq_smooth = h_tfSmooth_freq(freq,smooth_win)

if smooth_win ~=0
    nw_frq_list = round(freq.freq(1):smooth_win:freq.freq(end));
    nw_frq_list = nw_frq_list(1:end-1);
    nw_pow     = [];
    
    for f = 1:length(nw_frq_list)
        
        lm1 = find(round(freq.freq) == round(nw_frq_list(f)));
        lm2 = find(round(freq.freq) == round(nw_frq_list(f)+smooth_win));
        
        nw_pow(:,f,:) = squeeze(mean(freq.powspctrm(:,lm1:lm2,:),2));
        
    end
    
    frq_smooth           = freq;
    frq_smooth.freq      = nw_frq_list;
    frq_smooth.powspctrm = nw_pow;
else
    frq_smooth           = freq;
end