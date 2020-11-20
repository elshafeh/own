function new_freq = h_transformConn(freq,list_chan,list_name)

new_freq        = [];
new_freq.freq   = freq.time;
new_freq.time   = freq.time;
new_freq.dimord = freq.dimord;

for n= 1:length(list_name)
    
    new_freq.powspctrm(:,:,:,:) = mean(freq.powspctrm(list_chan{n},:,:,:),1)