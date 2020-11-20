clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load('/project/3015039.05/temp/nback/data/stat/mtm_decode_stat_with_all_chan.mat');
list_unique     = h_grouplabel(stat{1},'no');

load /project/3015039.05/temp/nback/data/template/com_btomeroi_select.mat
load /project/3015039.05/temp/nback/data/template/template_grid_0.5cm.mat


for nbig = 1:length(list_unique)
    
    source                  = [];
    source.pos              = template_grid.pos;
    source.dim              = template_grid.dim;
    source.inside           = template_grid.inside;
    source.pow              = nan(length(source.pos),1);
    
    
    flg                 = [];
    
    for nsmall = 1:length(list_unique{nbig,2})
        flg             = [flg;index_vox(index_vox(:,2) == list_unique{nbig,2}(nsmall),1)];
    end
    
    source.pow(flg)                                 = 1;
    
    cfg                                             = [];
    cfg.method                                      = 'surface';
    cfg.funparameter                                = 'pow';
    cfg.maskparameter                               = cfg.funparameter;
    cfg.funcolorlim                                 = [0 2];
    %     cfg.funcolormap                                 = brewermap(1,'*RdBu');
    cfg.projmethod                                  = 'nearest';
    cfg.camlight                                    = 'no';
    cfg.surffile                                    = 'surface_white_both.mat';
    cfg.surfinflated                                = 'surface_inflated_both.mat';
    list_view                                       = [0 90;90 0;-90 0];
    
    for nv = 1:size(list_view,1)
        
        ft_sourceplot(cfg, source);
        view(list_view(nv,:));
        saveas(gcf,['../figures/template/atlas/brainnetome/' list_unique{nbig} '.view' num2str(nv) '.png']);
        close all;
        
    end
    
end