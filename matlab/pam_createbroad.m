clear;

ft_path                 = '~/github/fieldtrip/template/atlas/afni/';
current_path            = '/Users/heshamelshafei/github/own/matlab/';

cd(ft_path);
atlas                   = ft_read_atlas('TTatlas+tlrc.HEAD');
atlas                   = ft_convert_units(atlas,'cm');

cd(current_path);
load ../data/stock/template_grid_0.5cm.mat;

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick1'; 
source_atlas            = ft_sourceinterpolate(cfg, atlas, source);

roi_interest            = [62 63 44 27 28 29 39 40 41];

index_vox               = [];
index_name              = {};
roi_found               = 0;

for d = 1:length(roi_interest)
    
    x               	=  find(ismember(atlas.brick1label,atlas.brick1label{roi_interest(d)}));
    both_hemi           =  find(source_atlas.brick1==x);
    
    for nhemi = [1 2]
        
        check_pos       = [both_hemi source.pos(both_hemi,:)];
        list_hemi       = {'left' 'right'};
        if nhemi == 1
            indxH       = check_pos(check_pos(:,2) < 0,1);
        else
            indxH       = check_pos(check_pos(:,2) > 0,1);
        end
        
        if ~isempty(indxH)
            roi_found                   = roi_found + 1;
            index_vox                   =  [index_vox ; indxH repmat(roi_found,size(indxH,1),1)];
            index_name{roi_found,1} 	=  [atlas.brick1label{roi_interest(d)} ' ' list_hemi{nhemi}];
        end
        
    end
    
    clear indxH x   
    
end

%%

source.pow                  = nan(length(source.pos),1);
source.pow(index_vox(:,1))  = index_vox(:,2);

cfg                         = [];
cfg.method                  = 'surface';
cfg.funparameter            = 'pow';
cfg.funcolormap             = brewermap(12,'Spectral');
cfg.projmethod              = 'nearest';
cfg.camlight                = 'no';
cfg.surffile                = 'surface_white_both.mat';
list_view                   = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];

for nview = [1 2]
    ft_sourceplot(cfg, source);
    view (list_view(nview,:));
    title(num2str(roi_interest));
    material dull
end