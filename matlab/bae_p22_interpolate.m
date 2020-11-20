clear ; clc ; 

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                          = [];
source.pos                      = template_grid.pos;
source.dim                      = template_grid.dim;
source.pow                      = [1:length(source.pos)]';

for iside = 3
    
    lst_side                                    = {'left','right','both'};
    lst_view                                    = [-95 1;95 1;0 50];
    
    %     z_lim                                       = 5;
    
    cfg                                         =   [];
    cfg.method                                  =   'surface';
    cfg.funparameter                            =   'pow';
    %     cfg.funcolorlim                             =   [-z_lim z_lim];
    %     cfg.opacitylim                              =   [-z_lim z_lim];
    cfg.opacitymap                              =   'rampup';
    
    cfg.colorbar                                =   'off';
    
    cfg.camlight                                =   'no';
    cfg.projthresh                              =   0.2;
    cfg.projmethod                              =   'nearest';
    cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    
end

% mri                             = ft_read_mri('/mnt/autofs/Aurelie/DATA/MEG/fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii'); % you should adjust this according to your directory
% [mni_x, mni_y, mni_z]           = h_voxelcoords(mri.dim, mri.transform);
%
%
% cfg                             = [];
% cfg.interpmethod                = 'nearest';
% cfg.parameter                   = 'pow' ;
% source_inter                    = ft_sourceinterpolate(cfg,source,mri);
%
% vox_list                        = [];
%
% for nvox = 1:length(source.pow)
%
%     fprintf('Looking at voxel %d out of %d\n',nvox,length(source.pow));
%
%     [where_x,where_y,where_z] = ind2sub(size(source_inter.pow),find(source_inter.pow == nvox));
%
%     if ~isempty(where_x) && ~isempty(where_y) && ~isempty(where_z)
%
%         vox_list              = [vox_list; where_x where_y where_z repmat(nvox,length(where_x),1)];
%
%     end
% end