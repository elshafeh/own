clear;

%load atlas and template MNI grid
load ../data/stock/template_grid_0.5cm.mat;
brainnetome                 = ft_read_atlas('~/github/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
brainnetome.tissuelabel     = brainnetome.tissuelabel';

template_grid               = ft_convert_units(template_grid,brainnetome.unit);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;

%interpolate atlas on the grid
cfg                         = [];
cfg.interpmethod            = 'nearest';
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, brainnetome, source);

for roi_interest = 1:length(brainnetome.tissuelabel)
    
    index_H                     = [];
    source.pow                  = nan(length(source.pos),1);
    label_interest              = brainnetome.tissuelabel(roi_interest);
    
    for d = 1:length(roi_interest)
        
        flg                     = 1;
        
        % find the index of each ROI in the MNI grid
        x                       =   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{roi_interest(d)}));
        indxH                   =   find(source_atlas.tissue==x);
        
        source.pow(indxH)       = flg;
        
        index_H                 =   [index_H ; indxH repmat(flg,size(indxH,1),1)];
        clear indxH x flg findme
        
    end
    
    %%
    
    if contains(label_interest,'Right')
        view_choice             = 2;
    else
        view_choice             = 1;
    end
    
    cfg                         = [];
    cfg.method                  = 'surface';
    cfg.funparameter            = 'pow';
    % cfg.maskparameter           = cfg.funparameter;
    % cfg.funcolorlim             = [-1 ];%max(index_H(:,2))];
    cfg.funcolormap             = brewermap(12,'Spectral');
    cfg.projmethod              = 'nearest';
    cfg.camlight                = 'no';
    cfg.surfinflated            = 'surface_inflated_both.mat';
    list_view                   = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];
    
    for nview = view_choice
        ft_sourceplot(cfg, source);
        view (list_view(nview,:));
        material dull
        title(num2str(roi_interest));
        
        saveas(gca, ['~/Desktop/brain/roi' num2str(roi_interest) '.png']);
        close all;
        
    end
    
end