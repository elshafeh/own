clear ;

addpath(genpath('kakearney-boundedline'));

list_mod        = {'vis','aud'};
load ../data/sub006_aud_sfn_dwnsample.BigB1.mat

time_axs        = data.time{1}; clear data;
i               = 0;

all_data        = [];

for nm = 1:2
    
    load(['../data/' list_mod{nm} 'allscores.mat']);
    
    all_data{nm}                        = [];
    
    for nf = 1:2
        
        i       = i + 1;
        
        for nb = 1:size(all_scores,2)
            
            if nf == 1
                mtrx_data               = squeeze(all_scores(:,nb,1,:));
            else
                mtrx_data               = squeeze(mean(squeeze(all_scores(:,nb,2:3,:)),2));
            end
            
            lm1                         = find(round(time_axs,2) == round(0.1,3));
            lm2                         = find(round(time_axs,2) == round(0.4,3));
            
            mtrx_data(find(mtrx_data < 0.5)) = 0.5;
            
            mtrx_data                   = mean(mtrx_data(:,lm1:lm2),2);
            
            all_data{nm}(nf,nb,:)       = mtrx_data; clear mtrx_data;
            
        end
    end
end

clearvars -except all_data;

all_res                                 = [];

for nm = 1:2
    for nf = 1:2
        
        x                               = all_data{nm}(nf,1,:);
        y                               = all_data{nm}(nf,2,:);
        
        [h,p]                           = ttest(x,y);
        
        all_res(nm,nf)                  = p;

    end
end

clearvars -except all_*;