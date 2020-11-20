clear ; clc ; close all;

vox_res               	= '0.5cm';

load(['../data/stock/template_grid_' vox_res '.mat']);

template_grid           = ft_convert_units(template_grid,'mm');
yeo17                   = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/yeo/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask_colin27.nii');

source               	= [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.inside           = template_grid.inside;

cfg                    	= [];
cfg.interpmethod     	= 'nearest'; %'linear'; %
cfg.parameter         	= 'tissue';
source_atlas           	= ft_sourceinterpolate(cfg, yeo17, source);

roi_interest           	= 1:length(yeo17.tissuelabel);
index_vox           	= [];

for d = 1:length(roi_interest)
    
    indxH           	= find(source_atlas.tissue==roi_interest(d));
    index_vox       	= [index_vox ; indxH repmat(roi_interest(d),length(indxH),1)];
    
    clear indxH x
    index_name{d}    	= ['yeo17 ' num2str(roi_interest(d))];% yeo17.tissuelabel{roi_interest(d)};
    clear indxH x
    
end

keep index_* source template_*

list_cut{1}             = [3 4];
list_cut{2}             = [3];
list_cut{3}             = 5;
list_cut{4}             = 5;
list_cut{5}             = [3];
list_cut{6}             = [1 3];
list_cut{7}             = [2 3];
list_cut{8}             = [1 3];
list_cut{9}             = NaN;
list_cut{10}         	= NaN;
list_cut{11}          	= NaN;
list_cut{12}           	= [1 3 4];
list_cut{13}         	= [1 2 3 4];
list_cut{14}         	= [3 4];
list_cut{15}         	= [3];
list_cut{16}         	= [1 3];
list_cut{17}         	= [1 3];

roi_interest            = unique(index_vox(:,2));

new_index               = [];
new_label               = {};
i                       = 0;

for d = 1:length(roi_interest)
    
    tmp              	= index_vox(index_vox(:,2) == roi_interest(d),1);
    tmp_pos             = source.pos(tmp,:);
    
    lmt_y               = mean(source.pos(:,2));
    lmt_z               = mean(source.pos(:,3));
    
    tmp_pos(tmp_pos(:,2) < lmt_y,4)     = 1;
    tmp_pos(tmp_pos(:,3) < lmt_z,5)     = 1;
    
    tmp_pos(tmp_pos(:,4) == 0 & tmp_pos(:,5) == 0,6) = 1;
    tmp_pos(tmp_pos(:,4) == 0 & tmp_pos(:,5) ~= 0,6) = 2;
    
    tmp_pos(tmp_pos(:,4) ~= 0 & tmp_pos(:,5) == 0,6) = 3;
    tmp_pos(tmp_pos(:,4) ~= 0 & tmp_pos(:,5) ~= 0,6) = 4;
    
    chk                 = list_cut{d};
    
    if isnan(chk)
        i = i;
    else
        
        if chk == 5
            i                   = i + 1;
            new_index           = [new_index; tmp repmat(i,length(tmp),1)]; clear tmp;
            new_label{i}        = ['roi' num2str(i)];
        else
            for n_sub = 1:length(chk)
                i               = i + 1;
                sub_temp        = tmp(find(tmp_pos(:,6) == chk(n_sub)));
                new_index       = [new_index; sub_temp repmat(i,length(sub_temp),1)];
                new_label{i}   = ['roi' num2str(i)];
            end
        end
        
    end
   
    
end

index_vox         	= new_index;
index_name      	= new_label;

keep  index_* source

roi_interest     	= unique(index_vox(:,2));


source.pow       	= nan(length(source.pos),1);

source.pow(index_vox(:,1))     = index_vox(:,2);

cfg                 = [];
cfg.method          = 'surface';
cfg.funparameter    = 'pow';
cfg.funcolormap     = 'jet';
cfg.projmethod      = 'nearest';
cfg.surfinflated    = 'surface_inflated_both_caret.mat';
cfg.camlight        = 'no';
cfg.funcolorlim     = [1 26];
ft_sourceplot(cfg, source);
material dull
view([-90 0]);

ft_sourceplot(cfg, source);
material dull
view([90 0]);

ft_sourceplot(cfg, source);
material dull

% for d = 1:length(roi_interest)
%     
%     source.pow       	= nan(length(source.pos),1);
%     tmp              	= index_vox(index_vox(:,2) == roi_interest(d),1);
%     
%     source.pow(tmp)     = 3;
%     
%     cfg                 = [];
%     cfg.method          = 'surface';
%     cfg.funparameter    = 'pow';
%     cfg.funcolormap     = 'jet';
%     cfg.projmethod      = 'nearest';
%     cfg.surfinflated    = 'surface_inflated_both_caret.mat';
%     cfg.camlight        = 'no';
%     cfg.funcolorlim     = [1 4];
%     ft_sourceplot(cfg, source);
%     material dull
%     view([-90 0]);
%     title(index_name{d});
%     
%     ft_sourceplot(cfg, source);
%     material dull
%     view([90 0]);
%     title(index_name{d});
%     
% end