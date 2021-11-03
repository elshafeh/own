function [vox_list] = func_findmaxvox_pam(cfg_in,source_in)

% input : 
% source_in: source struct with .pow and .pos
% cfg_in: 
% [1] .hemisphere: either 'left' or 'right;
% [2] .number_voxels: specify how many values u need
% [3] .direction: find (max) or (min)

[region_index,region_name]              = h_createIndexfieldtrip(source_in.pos,cfg_in.atlas_path);

roi_interest                            = [];

%select specific regions from atlas based on ROI
switch cfg_in.roi
    case 'visual'
        
        for nroi = 1:90
            ent_name                    = strsplit(region_name{nroi},'_');
            cut_name                    = ent_name{1};
            if strcmp(cut_name,'Occipital') || strcmp(cut_name,'Calcarine')
                roi_interest            = [roi_interest;nroi];
            end
        end
        
    case 'motor'
        for nroi = 1:90
            cut_name                    = strsplit(region_name{nroi},'_');
            cut_name                    = cut_name{1};
            if strcmp(cut_name,'Precentral') %|| strcmp(cut_name,'Paracentral') %strcmp(cut_name,'Precentral') || strcmp(cut_name,'Parietal') ||strcmp(cut_name,'Supp') || 
                roi_interest            = [roi_interest;nroi];
            end
        end
        
    case 'auditory'
        
        for nroi = 1:90
            ent_name                    = strsplit(region_name{nroi},'_');
            cut_name                    = ent_name{1};
            if strcmp(cut_name,'Heschl') % strcmp(cut_name,'Temporal')
                roi_interest            = [roi_interest;nroi];
            end
            if strcmp(cut_name,'Temporal') && strcmp(ent_name{2},'Sup')
                roi_interest            = [roi_interest;nroi];
            end
        end
        
end

clear nroi;


%only select regions of one hemisphere

roi_interest_side                       = [];

switch cfg_in.hemisphere
    case 'left'
        for nroi = 1:length(roi_interest)
            roi                         = region_name(nroi);
            cut_name                    = strsplit(roi{1},'_');
            cut_name                    = cut_name{end};
            if strcmp(cut_name,'L')
                roi_interest_side       = [roi_interest_side;roi_interest(nroi)];
            end
        end
    case 'right'
        for nroi = 1:length(roi_interest)
            roi                         = region_name(nroi);
            cut_name                    = strsplit(roi{1},'_');
            cut_name                    = cut_name{end};
            if strcmp(cut_name,'R')
                roi_interest_side       = [roi_interest_side;roi_interest(nroi)];
            end
        end
end

clear roi_interest;
clear nroi

i                                       = 0;

for nroi = 1:length(roi_interest_side)
    
    vct                                 = source_in.pow(region_index(region_index(:,2) == roi_interest_side(nroi),1));
    inx                                 = region_index(region_index(:,2) == roi_interest_side(nroi),1);
    
    for nvox = 1:cfg_in.number_voxels
        
        switch cfg_in.direction
            case 'min'
                fnd_vx                  = find(vct == nanmin(vct));
            case 'max'
                fnd_vx                  = find(vct == nanmax(vct));
        end
        
        
        i                             	= i +1;
        vox_list{i,1}                   = region_name{roi_interest_side(nroi)};
        vox_list{i,2}                   = inx(fnd_vx);
        vox_list{i,3}                   = vct(fnd_vx);
        vox_list{i,4}                   = cfg_in.hemisphere;
        
        vct(fnd_vx)                     = NaN; clear fnd_vx
        
    end
    
    clear vct inx nvox
    
end

vox_list                                = cell2table(vox_list,'VariableNames',{'ROI' 'Index' 'Value' 'Hemi'});

switch cfg_in.direction
    case 'min'
        vox_list                     	= sortrows(vox_list,{'Value'},{'ascend'});
    case 'max'
        vox_list                     	= sortrows(vox_list,{'Value'},{'descend'});
end