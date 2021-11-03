function [vox_list] = h_findMaxVoxelPerRegion(cfg_in,source_in)

% input : 
% source_in: source struct with .pow and .pos
% cfg_in: 
% [1] .hemisphere: either 'left' or 'right;
% [2] .number_voxels: specify how many values u need
% [3] .direction: find (max) or (min)

[region_index]                          = cfg_in.region_index;
[region_name]                           = cfg_in.region_name;

roi_interest                            = [];

switch cfg_in.hemisphere
    case 'left'
        for nroi = 1:90
            cut_name                    = strsplit(region_name{nroi},'_');
            hemi_name                  	= cut_name{end};
            roi_name                    = cut_name{1};
            if strcmp(hemi_name,'L')
                flg                     = find(strcmp(cfg_in.focus,roi_name));
                if ~isempty(flg)
                    roi_interest      	= [roi_interest;nroi];
                end
            end
        end
    case 'right'
        for nroi = 1:90
            cut_name                    = strsplit(region_name{nroi},'_');
            hemi_name                  	= cut_name{end};
            roi_name                    = cut_name{1};
            if strcmp(hemi_name,'R')
                flg                     = find(strcmp(cfg_in.focus,roi_name));
                if ~isempty(flg)
                    roi_interest      	= [roi_interest;nroi];
                end
            end
        end
end

clear noi

i                                       = 0;

for nroi = 1:length(roi_interest)
    
    vct                                 = source_in.pow(region_index(region_index(:,2) == roi_interest(nroi),1));
    inx                                 = region_index(region_index(:,2) == roi_interest(nroi),1);
    
    for nvox = 1:cfg_in.number_voxels
        
        switch cfg_in.direction
            case 'min'
                fnd_vx                  = find(vct == nanmin(vct));
            case 'max'
                fnd_vx                  = find(vct == nanmax(vct));
        end
        
        
        i                             	= i +1;
        vox_list{i,1}                   = region_name{roi_interest(nroi)};
        vox_list{i,2}                   = inx(fnd_vx);
        vox_list{i,3}                   = vct(fnd_vx);
        
        vct(fnd_vx)                     = NaN; clear fnd_vx
        
    end
    
    clear vct inx nvox
    
end

vox_list                                = cell2table(vox_list,'VariableNames',{'ROI' 'Index' 'Value'});

switch cfg_in.direction
    case 'min'
        vox_list                     	= sortrows(vox_list,{'Value'},{'ascend'});
    case 'max'
        vox_list                     	= sortrows(vox_list,{'Value'},{'descend'});
end