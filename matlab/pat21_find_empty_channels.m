function chn_list = find_empty_channels(freq)

freq.powspctrm = abs(freq.powspctrm);
chn_list = [];

for n = 1:275
    
    y = max(max(freq.powspctrm(n,:,:)));
    if y ~= 0
        chn_list = [chn_list n];
    end
    
end
