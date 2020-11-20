clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

addpath('../toolbox/sigstar-master/');

suj_list                                = [1:33 35:36 38:44 46:51];
target_count                            = [];

for nsuj = 1:length(suj_list)
   
    trialinfo                           = [];
    
    for nsess = 1:2
        fname                           = ['J:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '_trialinfo.mat'];
        load(fname);
        trialinfo                       = [trialinfo;index(:,[1 3])]; clear index
    end
    
    for nback = [4 5 6]
        flg                             = trialinfo(trialinfo(:,1) == nback,2);
        if nback == 4
            flg = flg+1;
        end
        target_count(nsuj,nback-3)      = length(find(flg==2)) ./ length(flg);
        
    end
    
end

keep target_count

[h1,p0v1] = ttest(target_count([1 2]));
[h2,p0v2] = ttest(target_count([1 3]));
[h3,p1v2] = ttest(target_count([2 3]));

keep target_count p0v1 p0v2 p1v2