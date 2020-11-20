function avg = h_freq2avg(freq,y1,y2,avg_over)

if strcmp(avg_over,'freq')
    pow             = squeeze(mean(freq.powspctrm(:,y1:y2,:),2));
    avg.time        = freq.time;
elseif strcmp(avg_over,'time')
    pow             = squeeze(mean(freq.powspctrm(:,:,y1:y2),3));
    avg.time        = freq.freq;
end

avg.dimord      = 'chan_time';
avg.label       = freq.label;
avg.avg         = pow;