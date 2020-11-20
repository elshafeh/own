function [max_info,min_info] = h_findMaxMinfreq(freq,n_max)

% finds max and min in a freq structure: input (tf structure, number of iterations)

nwfreq = freq ; 

for n = 1:n_max
    
    [~,maxV] = h_findMaxMinMatrix(nwfreq.powspctrm);
    
    [x,y,z] = h_find3d(maxV,nwfreq.powspctrm);
    
    max_info(n).chan = nwfreq.label{x};
    max_info(n).freq = nwfreq.freq(y);
    max_info(n).time = nwfreq.time(z);
    
    nwfreq.powspctrm(x,y,z) = 0 ;

end

max_info = struct2table(max_info);

nwfreq = freq; 

for n = 1:n_max
    
    [x,y,z] = h_find3d(maxV,nwfreq.powspctrm);
    
    min_info(n).chan = nwfreq.label{x};
    min_info(n).freq = nwfreq.freq(y);
    min_info(n).time = nwfreq.time(z);
    
    nwfreq.powspctrm(x,y,z) = 0 ;
    
end

min_info = struct2table(min_info);