function source =   h_towholebrain(cfg,mtrx)

load(cfg.index_file);
load(cfg.template_file);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

for nroi = 1:length(cfg.label)
    
    find_roi            	= find(strcmp(cfg.label{nroi},index_name));
    ix                      = index_vox(index_vox(:,2) == find_roi,1);
    source.pow(ix,1)        = mtrx(nroi);
    
end

