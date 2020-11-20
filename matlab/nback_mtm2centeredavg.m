clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51];
allpeaks                                = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                    = apeak; clear apeak;
    allpeaks(nsuj,2)                    = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)        = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    for nsess = [1 2]
        
        fname                       = ['J:/temp/nback/data/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        orig_data                   = data; clear data;
        
        list_time                   = -1.5:0.02:2;
        list_freq                   = 1:1:30;
        
        list_name                   = {'alpha.peak' 'beta.peak'};
        list_peak                   = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
        list_width                  = [1 2];
        
        for np = 1:length(list_peak)
            
            xi                      = list_peak(np) - list_width(np);
            yi                      = list_peak(np) + list_width(np);
            list_load               = round(xi:1:yi); clear xi yi;
            all_pow                 = [];
            
            for nfreq = 1:length(list_load)
                fname               = ['J:/temp/nback/data/tf/sub' num2str(suj_list(nsuj)) '.sess' num2str(nsess) '.orig.' num2str(list_load(nfreq)) 'Hz.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                all_pow           	= cat(4,all_pow,cat(3,data.trial{:})); % channel x time x trial x freq
            end
            
            all_pow                 = squeeze(nanmean(all_pow,4)); clear nfreq list_load
            all_pow                 = squeeze(num2cell(all_pow,[1 2]));
            
            data.trial              = all_pow; clear all_pow;
            data.fsample            = 1/0.02; % change it so that mne has a better time reading it in 
            
            fname_out               = ['J:/temp/nback/data/tf/sub' num2str(suj_list(nsuj)) '.sess' num2str(nsess) '.orig.' list_name{np} '.centered.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'data','-v7.3'); clear data;
            
        end
    end
end