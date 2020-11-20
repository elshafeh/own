function  part_virtsens  = h_ramaComputeVirtsensSepVoxels(dataica,spatialfilter,roi_list,arsenal_list,vox_order)

ft_progress('init','text',    'Please wait...');

for d = 1:length(roi_list)
    
    ft_progress(d/length(roi_list), 'Processing ROI %d from %d\n', d, length(roi_list));
    
    virtsens_sin{d} = [];
    tmp             = [arsenal_list{d,2}];
    
    ix = [];
    
    for i =1:length(tmp)
        ix = [ix; find(vox_order==tmp(i))];
    end
    
    clear i ;
    
    filt_slct       = spatialfilter(ix,:);
    
    clear ix tmp flg*
    
    for i=1:length(dataica.trial)
        virtsens_sin{d}.trial{i}    =   filt_slct*dataica.trial{i};
        %         virtsens_sin{d}.trial{i}    =   squeeze(nanmean(virtsens_sin{d}.trial{i},1));
    end
    
    clear i filt_slct
    
    virtsens_sin{d}.time       =   dataica.time;
    virtsens_sin{d}.fsample    =   dataica.fsample;
    
    for njeanne = 1:size(virtsens_sin{d}.trial{1})
        virtsens_sin{d}.label{njeanne}      =   [arsenal_list{d,1} '_' num2str(njeanne)];
    end
    
    clear filt_slct
    
end

part_virtsens              = ft_appenddata([],virtsens_sin{:});
part_virtsens.trialinfo    = dataica.trialinfo;