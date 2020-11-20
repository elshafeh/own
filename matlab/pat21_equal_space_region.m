clear ;clc ;dleiftrip_addpath;

load ../data/template/source_struct_template_MNIpos.mat

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);

indx =[];

for d = 1:90
    x       =     find(ismember(atlas.tissuelabel,atlas.tissuelabel{d}));
    ix      =     find(source_atlas.tissue==x);
    tmp     =     source.pos(ix,:);
    med     =     median(tmp);
    y       =     find(source.pos(:,1) == med(1) & source.pos(:,2) == med(2) & source.pos(:,3) == med(3));
    
    if ~isempty(y)
        indx    =     [indx; d y];
    else
        
        tmp = tmp(1:end-1,:);
        med     =     median(tmp);
        y       =     find(source.pos(:,1) == med(1) & source.pos(:,2) == med(2) & source.pos(:,3) == med(3));
        indx    =     [indx; d y];

    end
    
end

indx_arsenal = [indx(:,2) indx(:,1)]; list_arsenal = atlas.tissuelabel(1:90);  clearvars -except indx_arsenal list_arsenal

save ../data/yctot/index/explor.mat ;

% nw_source.pow = zeros(length(source.avg.pow),1) ;
% nw_source.pos = source.pos;
% new_source.dim = source.dim;
% 
% nw_source.pow(indx(:,2)) = 10;
% 
% intr = h_interpolate(nw_source);
% 
% cfg                     =   [];
% cfg.method              =   'surface';
% cfg.funparameter        =   'pow';
% cfg.funcolorlim         =   [-4 4];
% cfg.opacitylim          =   [-4 4];
% cfg.opacitymap          =   'rampup';
% cfg.colorbar            =   'off';
% cfg.camlight            =   'no';
% cfg.projthresh          =   0.2;
% cfg.projmethod          =   'nearest';
% cfg.surffile            =   'surface_white_both.mat';
% cfg.surfinflated        =   'surface_inflated_both_caret.mat';
% ft_sourceplot(cfg, nw_source); % wokrs without interpolating , i think..
% cfg.surffile            =   'surface_white_left.mat';
% cfg.surfinflated        =   'surface_inflated_left_caret.mat';
% ft_sourceplot(cfg, nw_source); % wokrs without interpolating , i think..
% cfg.surffile            =   'surface_white_right.mat';
% cfg.surfinflated        =   'surface_inflated_right_caret.mat';
% ft_sourceplot(cfg, nw_source); % wokrs without interpolating , i think..