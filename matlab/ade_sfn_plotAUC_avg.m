clear ;

addpath(genpath('kakearney-boundedline'));

list_mod        = {'vis','aud'};
load ../data/sub006_aud_sfn_dwnsample.BigB1.mat

time_axs        = data.time{1}; clear data;
i               = 0;

figure;

for nm = 1:2
    
    load(['../data/' list_mod{nm} 'allscores.mat']);
    
    for nf = 1:2
        
        i       = i + 1;
        subplot(2,2,i)
        hold on
        
        for nb = 1:size(all_scores,2)
            
            if nf == 1
                mtrx_data       = squeeze(all_scores(:,nb,1,:));
            else
                mtrx_data       = squeeze(mean(squeeze(all_scores(:,nb,2:3,:)),2));
            end
            
            mtrx_data(mtrx_data < 0.5) = 0.5;
            
            lm1                 = find(round(time_axs,2) == round(0.1,3));
            lm2                 = find(round(time_axs,2) == round(0.4,3));
            
            mtrx_data           = mean(mtrx_data(:,lm1:lm2),2);
            
            % Use the standard deviation over trials as error bounds:
            mean_data           = mean(mtrx_data,1);
            bounds              = std(mtrx_data, [], 1);
            bounds_sem          = bounds ./ sqrt(size(mtrx_data,1));
            
            bar(nb,mean_data);
            
            er                  = errorbar(nb,mean_data,bounds_sem,'LineWidth',1,'LineStyle','none');
            er.Color            = [0 0 0];
            er.LineStyle        = 'none';
            
            if nf == 1
                ylim([0.5 0.85]);
            else
                ylim([0.5 0.6]);
            end
            
            
        end
    end
end