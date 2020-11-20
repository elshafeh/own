clear ; clc ; addpath(genpath('/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/fieldtrip-20151124/'));

cd /Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/fieldtrip-20151124/template/atlas/afni/

atlas                   = ft_read_atlas('TTatlas+tlrc.HEAD');
atlas                   = ft_convert_units(atlas,'cm');

cd /Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/scripts_field

load /Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick1'; 
source_atlas            = ft_sourceinterpolate(cfg, atlas, source);

roi_interest            = 1:length(atlas.brick1label);

index_H         = [];
list_H          = {};
roi_found       = 0;

for d = 1:length(roi_interest)
    
    x                           =   find(ismember(atlas.brick1label,atlas.brick1label{roi_interest(d)}));
    indxH                       =   find(source_atlas.brick1==x);
    
    if ~isempty(indxH)
        roi_found                   = roi_found + 1;
        index_H                     =  [index_H ; indxH repmat(roi_found,size(indxH,1),1)];
        list_H{roi_found,1}         =  ['ch' num2str(roi_found)];
        
    end
    
    clear indxH x   
    
end

save('../data/index/Broad69.mat','index_H','list_H');