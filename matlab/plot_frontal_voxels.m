
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/template/template_grid_0.5cm.mat

atlas                           = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
list_H                          = {};

for nroi = 1:length(atlas.tissuelabel)
    
    newName                     = atlas.tissuelabel{nroi};
    newName                     = strsplit(newName,'_');
    newName                     = [newName{1:end}];
    atlas.newtissuelabel{nroi}  = newName;
    
    if strcmp(atlas.tissuelabel{nroi}(1:7),'Frontal') || strcmp(atlas.tissuelabel{nroi},'Cingulum_Ant_L') || strcmp(atlas.tissuelabel{nroi},'Cingulum_Ant_R')
        if strcmp(atlas.tissuelabel{nroi}(end)','L')
            
            %         roiName                     = atlas.tissuelabel{nroi};
            %         roiName                     = strsplit(roiName,'_');
            %         roiName                     = [roiName{1:end}];
            
            list_H{end+1}         = newName;
        end
    end
end

list_H                = unique(list_H);

clearvars -except atlas list_H template_grid

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

cfg                         = [];
cfg.interpmethod            = 'nearest';
cfg.parameter               = 'tissue';
atlas_stat                  = ft_sourceinterpolate(cfg, atlas, source);

index_H                     = [];

for d = 1:length(list_H)
    
    x                       =   find(ismember(atlas.newtissuelabel,list_H{d}));
    
    for nside = 1:length(x)
        
        indxH               =   find(atlas_stat.tissue==x(nside));
        index_H             =   [index_H ; indxH repmat(d,size(indxH,1),1)];
        
        clear indxH
    end
    
    clear x
    
end

clearvars -except index_H list_H;

save ../data/index/MNIFrontLeft.mat

% source.pow(indx(:,1))       = indx(:,2);
% 
% for iside = [1 2]
%     
%     lst_side                = {'left','right','both'};
%     lst_view                = [-95 1;95,11;0 50];
%     
%     z_lim                   =   length(frontal_list)+1;
%     
%     cfg                     =   [];
%     cfg.method              =   'surface';
%     cfg.funparameter        =   'pow';
%     cfg.funcolormap         =   'jet';
%     cfg.funcolorlim         =   [1 z_lim];
%     cfg.opacitylim          =   [1 z_lim];
%     cfg.opacitymap          =   'rampup';
%     cfg.colorbar            =   'off';
%     cfg.camlight            =   'no';
%     cfg.projmethod          =   'nearest';
%     cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     
%     ft_sourceplot(cfg, source);
%     view(lst_view(iside,:))
% 
% end

% for n = length(frontal_list):-1:1
%     
%     fprintf('%s\n',frontal_list{n});
%     
% end