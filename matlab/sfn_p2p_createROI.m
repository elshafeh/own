clear; 

load ../data/PaperIndex.mat

region_name     = {'occLR','audL','audR'};
region_index    = indx_tot(indx_tot(:,2) < 7,:);

clear arsenal_list indx_tot

region_index(region_index(:,2) < 3,2)                               = 1;
region_index(region_index(:,2) == 3 | region_index(:,2) == 5,2)     = 2;
region_index(region_index(:,2) == 4 | region_index(:,2) == 6,2)     = 3;

% region_index(region_index(:,2) > 1,2)      = 2;

save ../data/eNeuroPaper_AudVis_Index.mat ;
