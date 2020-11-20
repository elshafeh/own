clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                      	= [1:33 35:36 38:44 46:51];
allpeaks                     	= [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)          	= apeak; clear apeak;
    allpeaks(nsuj,2)         	= bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    for nsess = 1:2
        
        fname                  	= ['J:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        
    end
end