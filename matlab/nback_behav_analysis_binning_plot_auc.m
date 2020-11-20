clear;close all;

suj_list                          	= [1:33 35:36 38:44 46:51];
list_center                         = {'dwn70.bsl.auc','alpha.peak.centered.bsl.auc','beta.peak.centered.bsl.auc'};

for nlist = 1:3
    
    for nsuj = 1:length(suj_list)
        for nback = [0 1 2]
            
            fname                    	= ['J:/temp/nback/data/sens_level_auc/rt/sub' num2str(suj_list(nsuj)) '.decoding.rt.' num2str(nback) 'back.' list_center{nlist} '.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            mtrx_data(nsuj,nback+1,:)	= scores; clear scores;
        end
        
    end
    
    % Use the standard deviation over trials as error bounds:
    mean_data                           = squeeze(nanmean(mtrx_data,1));
    bounds                              = squeeze(nanstd(mtrx_data, [], 1));
    bounds_sem                          = squeeze(bounds ./ sqrt(size(mtrx_data,1)));
    
    clear mtrx_data;
    
    subplot(2,2,nlist)
    
    cfg_in.color                        = 'rgb';
    
    for nb = [2 3]
        
        boundedline(time_axis, mean_data(nb,:), bounds_sem(nb,:),['-' cfg_in.color(nb)],'alpha'); % alpha makes bounds transparent
        xlim([-0.1 2]);
        yticks([0.4 0.5 0.8]);
        ylim([0.4 0.8]);
        xticks(0:0.4:2);
        title(list_center{nlist});
        grid on;
        vline(0,'--k');
        hline(0.5,'--k');
        
    end
    
end