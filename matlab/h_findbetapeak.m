function [bpeak,orig_nan] = h_findbetapeak(freq_peak,freq_range)

% look for a peak in the beta range
cfg                           	= [];
cfg.method                      = 'linear' ;
cfg.foi                       	= freq_range;
bpeak                        	= alpha_peak(cfg,freq_peak);
bpeak                        	= bpeak(1);

orig_nan                        = 0;

%-% this to get peak for subjects with no peak

if isnan(bpeak)
    
    single_peak                 = [];
    orig_nan                    = 1;
    
    for nchan = 1:length(freq_peak.label)
        
        sub_freq_peak           = freq_peak;
        sub_freq_peak.powspctrm = freq_peak.powspctrm(nchan,:);
        sub_freq_peak.label   	= freq_peak.label(nchan);
        
        cfg                    	= [];
        cfg.method            	= 'linear';
        cfg.foi               	= freq_range;
        bpeak                 	= alpha_peak(cfg,sub_freq_peak);
        single_peak             = [single_peak;bpeak(1)]; clear bpeak;
        
    end
    
    bpeak                       = round(nanmedian(single_peak));
    
end

if isnan(bpeak)
    error('no BETA peak found..');
end