function freq_in = h_selectfreq(freq_in,freq_bounds,time_bounds)

% quickly select time and frequency points
% faster than FT :) 

f1                 	= nearest(freq_in.freq,freq_bounds(1));
f2                 	= nearest(freq_in.freq,freq_bounds(2));

t1                	= nearest(freq_in.time,time_bounds(1));
t2                 	= nearest(freq_in.time,time_bounds(2));

freq_in.powspctrm 	= freq_in.powspctrm(:,f1:f2,t1:t2);
freq_in.time      	= freq_in.time(t1:t2);
freq_in.freq      	= freq_in.freq(f1:f2); clear f1 f2 t1 t2;
