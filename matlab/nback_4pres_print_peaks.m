clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

allpeaks(:,3)                       = allpeaks(:,1) - 1; % alpha - 1
allpeaks(:,4)                       = allpeaks(:,1) + 1; % alpha + 1

allpeaks(:,5)                       = allpeaks(:,2) - 1; % beta - 1
allpeaks(:,6)                       = allpeaks(:,2) + 1; % beta + 1

allpeaks(:,7)                       = allpeaks(:,2) - 2; % beta - 2
allpeaks(:,8)                       = allpeaks(:,2) + 2; % beta + 2

list_peak                           = unique(round(allpeaks))';

keep list_peak

fprintf('[');
for n = 1:length(list_peak)
fprintf('%s,',num2str(list_peak(n)));
end
fprintf(']');