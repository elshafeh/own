clear ;

addpath(genpath('kakearney-boundedline'));

list_mod        = {'vis','aud'};
load ../data/sub006_aud_sfn_dwnsample.BigB1.mat

time_axs        = data.time{1}; clear data;
i               = 0;

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
            
            % Use the standard deviation over trials as error bounds:
            mean_data           = mean(mtrx_data,1);
            bounds              = std(mtrx_data, [], 1);
            bounds_sem          = bounds ./ sqrt(size(mtrx_data,1));
            
            if nb == 1
                boundedline(time_axs, mean_data, bounds_sem,'-b','alpha'); % alpha makes bounds transparent
            else
                boundedline(time_axs, mean_data, bounds_sem,'-r','alpha'); % alpha makes bounds transparent
            end
            
            if nf == 1
                ylim([0.5 1]);
            else
                ylim([0.5 0.7]);
            end
            
            xlim([-0.1 1])
            
            ax                  = gca();
            ax.XAxisLocation    = 'origin';
            ax.YAxisLocation    = 'origin';
            ax.TickDir          = 'out';
            box off;
            ax.XLabel.Position(2) = -60;
            
        end
    end
end