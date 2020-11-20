clear;

load ~/Dropbox/project_me/data/bil/itc.perc.mat

i           = 0;

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        
        i = i +1;
        newdata{i,1}     = ['sub' num2str(nsuj)];
        newdata{i,2}     = nbin;
        newdata{i,3}     = alldata(nsuj,nbin);
        
    end
end

keep newdata

alldata                 = cell2table(newdata,'VariableNames',{'SUB' 'BIN' 'PERC'});

writetable(alldata,'~/Dropbox/project_me/doc/bil/bil.itc.perc.txt');


% alldata             = num2cell(alldata);
% alldata             = cell2table(alldata,'VariableNames',{'Bin1' 'Bin2' 'Bin3' 'Bin4' 'Bin5'});
%
% writetable(alldata,'~/Dropbox/project_me/doc/bil/bil.itc.perc.txt');


% mean_data           = mean(alldata,1);
% bounds              = std(alldata, [], 1);
% bounds_sem          = bounds ./ sqrt(size(alldata,1));
%
% addpath('/Users/heshamelshafei/Documents/GitHub/RainCloudPlots/tutorial_matlab/');
% addpath('/Users/heshamelshafei/Documents/GitHub/me/toolbox/cbrewer/');
% addpath('/Users/heshamelshafei/Documents/GitHub/Robust_Statistical_Toolbox/');
%
% read into cell array of the appropriate dimensions
% for nbin = 1:size(alldata,2)
%     data{nbin} = alldata(:,nbin);
% end
%
% means = cellfun(@mean, data);
% variances = cellfun(@std, data);
