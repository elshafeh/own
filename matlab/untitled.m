clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

list_feat           = {'pre.vs.retro' 'pre.ori.vs.spa' 'retro.ori.vs.spa'};

for nfeat = 1:length(list_feat)
    
    figure;
    
    for nchan = 1:22
        
        subplot(5,5,nchan)
        
        mtrx_data         = [];
        
        for nsuj = 1:length(suj_list)
            
            try
                load(['D:/Dropbox/project_me/data/bil/virt/' suj_list{nsuj} '.wallis.decodingcue.' list_feat{nfeat} '.correct.auc.mat']);
                mtrx_data     = [mtrx_data;scores(nchan,:)]; clear scores;
            catch
                mtrx_data     = mtrx_data;
            end
            
        end
        
        mean_data                           = nanmean(mtrx_data,1);
        bounds                              = nanstd(mtrx_data, [], 1);
        bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));
        
        plot(time_axis, mtrx_data, 'Color', [0.8 0.8 0.8]);
        boundedline(time_axis, mean_data, bounds_sem,'-b','alpha'); % alpha makes bounds transparent
        
%         ylim([0.3 1]);
        xlim(time_axis([1 end]));
        hline(0.5,'--r');
        vline(0,'--r');
        
        if nchan == 3
            title(['N = ' num2str(size(mtrx_data,1)) ' ' list_feat{nfeat}]);
        end
        
        
    end
end