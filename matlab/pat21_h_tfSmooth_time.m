function frq_smooth = h_tfSmooth_time(freq,smooth_win)

if smooth_win ~=0
    nw_tm_list = freq.time(1):smooth_win:freq.time(end);
    nw_tm_list = nw_tm_list(1:end-1);
    nw_pow     = [];
    
    for t = 1:length(nw_tm_list)
        
        lm1 = find(round(freq.time,3) == round(nw_tm_list(t),3));
        lm2 = find(round(freq.time,3) == round(nw_tm_list(t)+smooth_win,3));
        
        nw_pow(:,:,t) = squeeze(mean(freq.powspctrm(:,:,lm1:lm2),3));
        
    end
    
    frq_smooth           = freq;
    frq_smooth.time      = nw_tm_list;
    frq_smooth.powspctrm = nw_pow;
    
else
    frq_smooth           = freq;
end




