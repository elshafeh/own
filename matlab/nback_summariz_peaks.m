clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];
allpeaks                                        = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                            = apeak; clear apeak;
    allpeaks(nsuj,2)                            = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)                = nanmean(allpeaks(:,2));

keep allpeaks

% Use the standard deviation over trials as error bounds:

mtrx_data                           = allpeaks(:,2);
mean_data                           = nanmean(mtrx_data,1);
bounds                              = nanstd(mtrx_data, [], 1);
bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));