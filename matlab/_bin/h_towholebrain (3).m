function source =   h_towholebrain(mtrx,index_file,template_file)

load(index_file);
load(template_file);

load roi1cm_actual_labels.mat
roi_interest                = [1:100 118:159 172:206];

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

for nroi = 1:length(roi_interest)
    
    find_roi                = find(strcmp(data_name{roi_interest(nroi)},index_name));
    ix                      = index_vox(index_vox(:,2) == find_roi,1);
    source.pow(ix,1)        = mtrx(nroi);
    
end

