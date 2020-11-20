function avg = h_freq2avg(freq,freq_limit,avg_over)

if strcmp(avg_over,'avg_over_freq')
    y1              = find(round(freq.freq)== round(freq_limit(1)));
    y2              = find(round(freq.freq)== round(freq_limit(2))); 
end

pow             = squeeze(mean(freq.powspctrm(:,y1:y2,:),2));

avg.dimord      = 'chan_time';
avg.time        = freq.time;
avg.label       = freq.label;
avg.avg         = pow;