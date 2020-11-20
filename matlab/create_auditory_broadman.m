clear ; clc ; addpath(genpath('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/fieldtrip-20151124/'));

atlas  = ft_read_atlas('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/fieldtrip-20151124/template/atlas/afni/TTatlas+tlrc.HEAD');
atlas  = ft_convert_units(atlas,'cm');

load /Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/data/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick1'; 
source_atlas            = ft_sourceinterpolate(cfg, atlas, source);

roi_interest            = [39:41 62:63 44];

indx = [];

for d = 1:length(roi_interest)
    
    x                       =   find(ismember(atlas.brick1label,atlas.brick1label{roi_interest(d)}));
    indxH                   =   find(source_atlas.brick1==x);
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x   
    
end

index_H                     = [];
list_H                      = {};
ix                          = 0;

temp_list = {'vis_broad17','vis_broad18','vis_broad19','aud_broad41','aud_broad42','aud_broad22'};

for nroi = 1:length(roi_interest)
    
    roi_slct = indx(indx(:,2) == nroi);
    
    for nvox = 1:length(roi_slct)
        
        if source.pos(roi_slct(nvox,1),1) < 0
            roi_slct(nvox,2) = 1;
        else
            roi_slct(nvox,2) = 2;
        end
        
    end
    
    ix                          = ix + 1;
    index_H                     = [index_H; roi_slct(roi_slct(:,2)==1,1) repmat(ix,size(roi_slct(roi_slct(:,2)==1,1),1),1)];
    
    list_H{ix}                  = [temp_list{nroi} '_L'];
    
    ix                          = ix + 1;
    index_H                     = [index_H; roi_slct(roi_slct(:,2)==2,1) repmat(ix,size(roi_slct(roi_slct(:,2)==2,1),1),1)];
    
    list_H{ix}                  = [temp_list{nroi} '_R'];

    
end

clearvars -except index_H list_H template_grid

save('../data_fieldtrip/index/broadmanAuditoryOccipital_Separate.mat','index_H','list_H');

% index_H = index_H(mod(index_H(:,2),2)~=0,:);
% index_H = index_H(index_H(:,2) > 6,:);

% roi_interest = unique(index_H(:,2));
% source                      = [];
% source.pos                  = template_grid.pos ;
% source.dim                  = template_grid.dim ;
% source.pow                  = nan(length(source.pos),1);

% for nroi = 1:length(roi_interest)
%     source.pow(index_H(index_H(:,2) == roi_interest(nroi),1)) = nroi*1;
% end
%
% z_lim                                       = 15;
%
% cfg                                         =   [];
% cfg.method                                  =   'surface';
% cfg.funparameter                            =   'pow';
% cfg.funcolorlim                             =   [0 z_lim];
% cfg.opacitylim                              =   [0 z_lim];
% cfg.opacitymap                              =   'rampup';
% cfg.colorbar                                =   'off';
% cfg.camlight                                =   'no';
% cfg.projmethod                              =   'nearest';
% cfg.surffile                                =   'surface_white_both.mat';
% cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
% ft_sourceplot(cfg, source);

