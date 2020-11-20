function source =   h_towholebrain(mtrx,index_file,template_file)

load(index_file);
load(template_file);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

for nroi = 1:length(index_name) 
    ix                      = index_vox(index_vox(:,2) == nroi,1);
    source.pow(ix,1)        = mtrx(nroi);
end

