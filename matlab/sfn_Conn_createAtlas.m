clear; 

load ../data/eNeuroPaper_AudVis_Index.mat
load '/Volumes/heshamshung/Fieldtripping6Dec2018/data/index/TD_BU_index.mat'

list_interest = sort([8 12 22 21 20 19 18 17 7 6 4 3 2]);

for nroi = 1:length(list_interest)
    
    tmp             = index_H(index_H(:,2) == list_interest(nroi),:);
    ix              = 3+nroi;
    
    tmp(:,2)        = ix;
    region_index    = [region_index;tmp]; clear tmp;
    region_name{ix} = ['TD' num2str(list_interest(nroi))]; clear ix;
    
end

clearvars -except region_*

save ../data/eNeuroPaper_AudVis_Index_plus_TDSchaef.mat

